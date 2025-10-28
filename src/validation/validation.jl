# =============================================================================
# GTFS VALIDATION SYSTEM - HELPER FUNCTIONS
# =============================================================================

"""
    validate_all_tables!(messages, gtfs_feed, table_name, df)

Validate all aspects of a single table in one pass using vectorized operations.
This combines type validation, constraints, enums, and ID references.

# Arguments
- `messages`: Vector to append validation messages to
- `gtfs_feed`: Complete GTFS feed for cross-table validation
- `table_name`: Symbol name of the table being validated
- `df`: DataFrame containing the table data
"""
function validate_all_tables!(messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule, table_name::Symbol, df)
    # Get all rules for this table at once - reduces lookups
    field_types = get(FIELD_TYPES, table_name, [])
    field_rules = get(FIELD_RULES, table_name, [])
    constraints = get(FIELD_CONSTRAINTS, table_name, [])
    enum_rules = get(ENUM_RULES, table_name, [])
    id_refs = get(FIELD_ID_REFERENCES, table_name, [])

    # Process all fields in the table
    for field_info in field_types
        validate_field_all_aspects!(
            messages, gtfs_feed, table_name, df, field_info,
            field_rules, constraints, enum_rules, id_refs
        )
    end

    # Validate table-level conditions (file presence, etc.)
    return validate_table_conditions!(messages, gtfs_feed, table_name)
end

"""
    validate_field_all_aspects!(messages, gtfs_feed, table_name, df, field_info,
                              field_rules, constraints, enum_rules, id_refs)

Validate a single field against all validation rules using vectorized operations.
This is the core optimization - instead of 6 separate passes, we do everything in one.

# Arguments
- `messages`: Vector to append validation messages to
- `gtfs_feed`: Complete GTFS feed for cross-table validation
- `table_name`: Symbol name of the table
- `df`: DataFrame containing the table data
- `field_info`: Field type information from FIELD_TYPES
- `field_rules`: Field presence rules from FIELD_RULES
- `constraints`: Field constraints from FIELD_CONSTRAINTS
- `enum_rules`: Enum validation rules from ENUM_RULES
- `id_refs`: ID reference rules from FIELD_ID_REFERENCES
"""
function validate_field_all_aspects!(
        messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule,
        table_name::Symbol, df, field_info, field_rules, constraints,
        enum_rules, id_refs
    )
    field_name = field_info.field
    !DataFrames.hasproperty(df, field_name) && return

    column = df[!, field_name]
    column_length = length(column)

    # Pre-allocate validation arrays for better performance
    type_valid, constraint_valid, enum_valid, ref_valid = prepare_validation_arrays(column_length)

    # Vectorized validation - process entire column at once
    type_valid = validate_column_types(column, field_info.gtfs_type)
    constraint_valid = validate_column_constraints(column, constraints, field_name)
    enum_valid = validate_column_enums(column, enum_rules, field_name)
    ref_valid = validate_column_references(column, id_refs, field_name, gtfs_feed)

    # Add messages for invalid rows (vectorized)
    add_validation_messages!(
        messages, table_name, field_name,
        type_valid, constraint_valid, enum_valid, ref_valid
    )

    # Validate field presence conditions
    return validate_field_presence!(messages, gtfs_feed, table_name, df, field_name, field_rules)
end

"""
    validate_field_presence!(messages, gtfs_feed, table_name, df, field_name, field_rules)

Validate field presence rules using optimized logic.

# Arguments
- `messages`: Vector to append validation messages to
- `gtfs_feed`: Complete GTFS feed for cross-table validation
- `table_name`: Symbol name of the table
- `df`: DataFrame containing the table data
- `field_name`: Symbol name of the field
- `field_rules`: Vector of field presence rules
"""
function validate_field_presence!(
        messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule,
        table_name::Symbol, df, field_name::Symbol, field_rules
    )
    # Find rules for this specific field
    field_rule = findfirst(rule -> rule.field == field_name, field_rules)
    field_rule === nothing && return

    rule = field_rules[field_rule]
    presence = rule.presence

    # Check if column exists
    if !df_has_column(df, field_name)
        # For conditionally required/forbidden fields, we need to check conditions even when field is missing
        if presence in ["Conditionally Required", "Conditionally Forbidden"]
            check_conditional!(messages, gtfs_feed, df, table_name, rule)
        else
            handle_missing_field!(messages, table_name, field_name, presence)
        end
        return
    end

    col_data = df[!, field_name]

    # Dispatch based on presence type
    if presence == "Required"
        check_required!(messages, table_name, field_name, col_data)
    elseif presence == "Optional"
        # Optional fields are always valid
        return
    else
        # Conditional presence
        check_conditional!(messages, gtfs_feed, df, table_name, rule)
    end
end

"""
    validate_table_conditions!(messages, gtfs_feed, table_name)

Validate table-level conditions using optimized logic.

# Arguments
- `messages`: Vector to append validation messages to
- `gtfs_feed`: Complete GTFS feed
- `table_name`: Symbol name of the table
"""
function validate_table_conditions!(messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule, table_name::Symbol)
    spec = get(FILE_RULES, table_name, nothing)
    spec === nothing && return

    presence = spec.presence
    exists = gtfs_has_table(gtfs_feed, table_name)

    return if presence == "Required"
        check_required_table!(messages, table_name, exists)
    elseif presence == "Optional"
        push!(messages, ValidationMessage(table_name, nothing, "Optional table '$table_name' validation skipped", :info))
    else
        # Conditional presence
        check_conditional_table!(messages, gtfs_feed, table_name, spec)
    end
end

# =============================================================================
#  HELPER FUNCTIONS
# =============================================================================

function handle_missing_field!(messages::Vector{ValidationMessage}, table_name::Symbol, field_name::Symbol, presence::String)
    return if presence == "Required"
        push!(messages, ValidationMessage(table_name, field_name, "Required field '$field_name' not present in table", :error))
    elseif presence == "Optional"
        push!(messages, ValidationMessage(table_name, field_name, "Optional field '$field_name' validation skipped", :info))
    else
        push!(messages, ValidationMessage(table_name, field_name, "Field '$field_name' not present - conditional validation skipped", :info))
    end
end

function check_required!(messages::Vector{ValidationMessage}, table_name::Symbol, field_name::Symbol, col_data)
    missing_count = count(ismissing, col_data)
    return if missing_count > 0
        push!(messages, ValidationMessage(table_name, field_name, "Required field '$field_name' has $missing_count missing values", :error))
    else
        push!(messages, ValidationMessage(table_name, field_name, "Required field '$field_name' has no missing values", :info))
    end
end

function check_conditional!(messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule, df, table_name::Symbol, rule)
    field = rule.field
    conditions = get(rule, :conditions, [])

    same_table, cross_table = _separate_conditions(conditions, table_name)

    cross_table_met = _evaluate_cross_table_conditions(gtfs_feed, cross_table)
    if !cross_table_met
        return
    end

    exists, column = _prepare_field_data(df, field)

    for (row_idx, row) in enumerate(DataFrames.eachrow(df))
        _validate_conditional_row!(
            messages, gtfs_feed, df, table_name, rule, row, row_idx,
            same_table, cross_table_met, exists, column
        )
    end
    return
end

function _validate_conditional_row!(
        messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule, df,
        table_name::Symbol, rule, row, row_idx,
        same_table, cross_table_met, exists, column
    )
    field = rule.field

    # Evaluate same-table conditions for this row
    same_table_met = _evaluate_same_table_conditions(row, same_table, rule)

    # Both conditions must be met
    conditions_met = same_table_met && cross_table_met

    if !conditions_met
        return
    end

    # Get cell value
    cell_value = exists ? column[row_idx] : missing

    # Validate based on rule type
    return if get(rule, :required, false)
        _validate_conditionally_required!(messages, table_name, field, row_idx, cell_value)
    elseif get(rule, :forbidden, false)
        _validate_conditionally_forbidden!(messages, table_name, field, row_idx, cell_value)
    end
end

function _validate_conditionally_required!(
        messages::Vector{ValidationMessage}, table_name::Symbol,
        field_name::Symbol, row_idx::Int, cell_value
    )
    return if ismissing(cell_value)
        push!(
            messages, ValidationMessage(
                table_name,
                field_name,
                "Row $row_idx: Conditionally required field '$field_name' is missing (condition met)",
                :error
            )
        )
    else
        push!(
            messages, ValidationMessage(
                table_name,
                field_name,
                "Row $row_idx: Conditionally required field '$field_name' is present (condition met)",
                :info
            )
        )
    end
end

function _validate_conditionally_forbidden!(
        messages::Vector{ValidationMessage}, table_name::Symbol,
        field_name::Symbol, row_idx::Int, cell_value
    )
    return if !ismissing(cell_value) && cell_value != ""
        push!(
            messages, ValidationMessage(
                table_name,
                field_name,
                "Row $row_idx: Conditionally forbidden field '$field_name' has value '$cell_value' (condition met)",
                :error
            )
        )
    else
        push!(
            messages, ValidationMessage(
                table_name,
                field_name,
                "Row $row_idx: Conditionally forbidden field '$field_name' is empty (condition met)",
                :info
            )
        )
    end
end

function check_required_table!(messages::Vector{ValidationMessage}, table_name::Symbol, exists::Bool)
    return if !exists
        push!(messages, ValidationMessage(table_name, nothing, "Required table '$table_name' is missing", :error))
    else
        push!(messages, ValidationMessage(table_name, nothing, "Required table '$table_name' is present", :info))
    end
end

function check_conditional_table!(messages::Vector{ValidationMessage}, gtfs_feed::GTFSSchedule, table_name::Symbol, spec)
    exists = gtfs_has_table(gtfs_feed, table_name)
    any_relation_met = false

    for rel in spec.relations
        if _evaluate_table_relation_conditions(gtfs_feed, rel)
            any_relation_met = true
            _validate_table_relation!(messages, table_name, exists, rel)
        end
    end

    return if !any_relation_met
        push!(messages, ValidationMessage(table_name, nothing, "Table '$table_name' conditions not met - no validation required", :info))
    end
end

function _validate_table_relation!(messages::Vector{ValidationMessage}, table_name::Symbol, exists::Bool, rel)
    return if get(rel, :required, false)
        _validate_conditionally_required_table!(messages, table_name, exists)
    elseif get(rel, :forbidden, false)
        _validate_conditionally_forbidden_table!(messages, table_name, exists)
    else
        # Optional case - table can be absent without error
        push!(messages, ValidationMessage(table_name, nothing, "Table '$table_name' is optional (alternative exists)", :info))
    end
end

function _validate_conditionally_required_table!(messages::Vector{ValidationMessage}, table_name::Symbol, exists::Bool)
    return if !exists
        push!(messages, ValidationMessage(table_name, nothing, "Conditionally required table '$table_name' is missing", :error))
    else
        push!(messages, ValidationMessage(table_name, nothing, "Conditionally required table '$table_name' is present", :info))
    end
end

function _validate_conditionally_forbidden_table!(messages::Vector{ValidationMessage}, table_name::Symbol, exists::Bool)
    return if exists
        push!(messages, ValidationMessage(table_name, nothing, "Conditionally forbidden table '$table_name' is present", :error))
    else
        push!(messages, ValidationMessage(table_name, nothing, "Conditionally forbidden table '$table_name' is correctly absent", :info))
    end
end
