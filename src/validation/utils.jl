# =============================================================================
# GTFS DATA ACCESS HELPERS
# =============================================================================

function filename_to_symbol(filename::String)
    table = replace(filename, ".txt" => "", ".geojson" => "")
    return Symbol(replace(table, "." => "_"))
end

function get_dataframe(gtfs::GTFSSchedule, filename::String)
    table = replace(filename, r"\.(txt|geojson)$" => "")
    table = Symbol(table)
    gtfs_has_table(gtfs, table) || return nothing
    return get(gtfs, table, nothing)
end

function get_dataframe(gtfs::GTFSSchedule, table::Symbol)
    gtfs_has_table(gtfs, table) || return nothing
    return get(gtfs, table, nothing)
end

function gtfs_has_table(gtfs, table::Symbol)
    return haskey(gtfs, table) && get(gtfs, table, nothing) !== nothing
end

df_has_column(df, col_sym::Symbol) = DataFrames.hasproperty(df, col_sym)
df_has_column(df, col_str::String) = DataFrames.hasproperty(df, Symbol(col_str))

# =============================================================================
# VALIDATION RESULT HELPERS
# =============================================================================

function count_by_severity(messages::Vector{ValidationMessage})
    errors = count(m -> m.severity == :error, messages)
    warnings = count(m -> m.severity == :warning, messages)
    return (errors = errors, warnings = warnings)
end

function create_validation_result(messages::Vector{ValidationMessage}, context::String)
    counts = count_by_severity(messages)
    summary = "$context: $(counts.errors) errors, $(counts.warnings) warnings"
    return ValidationResult(messages, summary)
end

function _group_messages_by_table_and_field(messages::Vector{ValidationMessage})
    table_groups = Dict{String, Dict{Union{String, Nothing}, Vector{ValidationMessage}}}()
    for msg in messages
        table_key = string(msg.table)
        if !haskey(table_groups, table_key)
            table_groups[table_key] = Dict{Union{String, Nothing}, Vector{ValidationMessage}}()
        end
        field_key = msg.field === nothing ? nothing : string(msg.field)
        if !haskey(table_groups[table_key], field_key)
            table_groups[table_key][field_key] = ValidationMessage[]
        end
        push!(table_groups[table_key][field_key], msg)
    end
    return table_groups
end

function _print_table_errors(table::String, table_errors::Dict{Union{String, Nothing}, Vector{ValidationMessage}})
    println("File: $table")
    for (field_name, field_errors) in table_errors
        field_display = field_name === nothing ? "File-level" : "Field: $field_name"
        println("  $field_display ($(length(field_errors)) messages)")
        for error in field_errors
            println("    $(error.message)")
        end
    end
    return println()
end

"""
    print_validation_results(result::ValidationResult)

Print validation results in a formatted, human-readable format.

# Arguments
- `result::ValidationResult`: The validation result to print

# Example
```julia
result = GTFSSchedules.Validations.validate_gtfs(gtfs)
GTFSSchedules.Validations.print_validation_results(result)
```
"""
function print_validation_results(result::ValidationResult)
    println("GTFS Validation Results")
    println("======================")
    println(result.summary)
    println()

    if !has_validation_errors(result)
        println("✓ All validations passed!")
        return
    end

    table_groups = _group_messages_by_table_and_field(result.messages)
    for (table, table_errors) in table_groups
        _print_table_errors(table, table_errors)
    end
    return
end

"""
    has_validation_errors(result::ValidationResult) -> Bool

Check if a validation result contains any errors.

# Arguments
- `result::ValidationResult`: The validation result to check

# Returns
- `Bool`: `true` if there are validation errors, `false` otherwise

# Example
```julia
result = GTFSSchedules.Validations.validate_gtfs(gtfs)
if GTFSSchedules.Validations.has_validation_errors(result)
    println("Feed has validation errors")
end
```
"""
function has_validation_errors(result::ValidationResult)
    return any(m -> m.severity == :error, result.messages)
end

# =============================================================================
# CONDITION EVALUATION HELPERS
# =============================================================================

function _condition_holds(gtfs, cond)::Bool
    if !haskey(cond, :type)
        return true
    end

    if cond[:type] === :file
        return _evaluate_table_condition(gtfs, cond)
    elseif cond[:type] === :field
        return _evaluate_field_condition(gtfs, cond)
    else
        return true  # unknown cond type is a no-op
    end
end

function _evaluate_table_condition(gtfs, cond)
    table = Symbol(cond[:file])
    exists = gtfs_has_table(gtfs, table)
    return cond[:must_exist] ? exists : !exists
end

function _evaluate_field_condition(gtfs, cond)
    table = Symbol(cond[:file])
    if !gtfs_has_table(gtfs, table)
        return false
    end

    df = get_dataframe(gtfs, table)
    df === nothing && return false

    col = cond[:field]
    if !df_has_column(df, col)
        return false
    end

    val = cond[:value]
    if val == "defined"
        return _check_field_defined(df, col)
    else
        return _check_field_value(df, col, val)
    end
end

function _check_field_defined(df, col)
    for row in DataFrames.eachrow(df)
        if !ismissing(getproperty(row, col))
            return true
        end
    end
    return false
end

function _check_field_value(df, col, val)
    parsed = tryparse(Float64, String(val))
    for row in DataFrames.eachrow(df)
        cell = getproperty(row, col)
        if ismissing(cell)
            continue
        end
        if string(cell) == string(val)
            return true
        end
        if parsed !== nothing && (cell == parsed)
            return true
        end
    end
    return false
end

# =============================================================================
# FIELD VALIDATION HELPERS
# =============================================================================

function _extract_allowed_values(enum_values)
    return [ev.value for ev in enum_values]
end

function _collect_valid_reference_values(gtfs_feed::GTFSSchedule, references)
    valid_values = Set{String}()

    for ref in references
        target_table = ref.table
        target_field = ref.field

        df = get_dataframe(gtfs_feed, target_table)
        df === nothing && continue

        if df_has_column(df, target_field)
            column = df[!, target_field]
            for value in column
                if !ismissing(value) && string(value) != ""
                    push!(valid_values, string(value))
                end
            end
        end
    end

    return valid_values
end

function _format_reference_description(references)
    if length(references) == 1
        ref = references[1]
        return "$(ref.table).$(ref.field)"
    else
        ref_descriptions = ["$(ref.table).$(ref.field)" for ref in references]
        return join(ref_descriptions, ", ")
    end
end

function _evaluate_table_relation_conditions(gtfs::GTFSSchedule, rel)
    conditions = get(rel, :when_all, [])
    return all(cond -> _condition_holds(gtfs, cond), conditions)
end

function _separate_conditions(conditions, table::Symbol)
    same_table = filter(c -> !haskey(c, :file) || c[:file] == table, conditions)
    cross_table = filter(c -> haskey(c, :file) && c[:file] != table, conditions)
    return same_table, cross_table
end

function _prepare_field_data(df, field::Symbol)
    exists = df_has_column(df, field)
    column = exists ? df[!, field] : nothing
    return exists, column
end

function _evaluate_cross_table_conditions(gtfs::GTFSSchedule, cross_table)
    return isempty(cross_table) ||
        any(c -> _condition_holds_for_row_cross_table(gtfs, c), cross_table)
end

function _evaluate_same_table_conditions(row, same_table, rule)
    if isempty(same_table)
        return true
    end

    if get(rule, :required, false)
        # Required rules: use AND logic (all conditions must be true)
        return all(cond -> _condition_holds_for_row(row, cond), same_table)
    elseif get(rule, :forbidden, false)
        # Forbidden rules: use OR logic (any condition being true triggers the rule)
        return any(cond -> _condition_holds_for_row(row, cond), same_table)
    else
        return true  # Optional rules
    end
end

function _condition_holds_for_row(row::DataFrames.DataFrameRow, cond)
    if !haskey(cond, :type)
        return true
    end

    if cond[:type] === :field
        return _evaluate_field_condition_for_row(row, cond)
    end

    # For other condition types, return true (not row-specific)
    return true
end

function _evaluate_field_condition_for_row(row::DataFrames.DataFrameRow, cond)
    field_name = _extract_field_name(cond[:field])
    row_value = _get_row_field_value(row, field_name)
    expected_value = cond[:value]

    return _compare_field_values(row_value, expected_value)
end

function _extract_field_name(field_name::Symbol)
    field_str = string(field_name)
    return occursin(".", field_str) ? Symbol(split(field_str, ".")[end]) : field_name
end

function _extract_field_name(field_expr::Expr)
    # Handle expressions like :(stop_times.start_pickup_drop_off_window)
    if field_expr.head == :quote && length(field_expr.args) == 1
        field_name = field_expr.args[1]
        if isa(field_name, Symbol)
            field_str = string(field_name)
            return occursin(".", field_str) ? Symbol(split(field_str, ".")[end]) : field_name
        end
    end
    # Fallback: convert to string and extract last part
    field_str = string(field_expr)
    return occursin(".", field_str) ? Symbol(split(field_str, ".")[end]) : Symbol(field_str)
end

function _get_row_field_value(row::DataFrames.DataFrameRow, field_name::Symbol)
    return DataFrames.hasproperty(row, field_name) ? getproperty(row, field_name) : missing
end

function _compare_field_values(row_value, expected_value)
    if expected_value == ""
        # Empty string condition: check if field is missing or empty
        return ismissing(row_value) || string(row_value) == ""
    elseif expected_value == "defined"
        # Defined condition: check if field is not missing and not empty
        return !ismissing(row_value) && string(row_value) != ""
    else
        # Exact match: compare string representations
        return !ismissing(row_value) && string(row_value) == string(expected_value)
    end
end

function _condition_holds_for_row_cross_table(gtfs::GTFSSchedule, cond)
    if !haskey(cond, :type) || cond[:type] !== :field
        return true
    end

    target_file = cond[:file]
    field_name = _extract_field_name(cond[:field])

    df = get_dataframe(gtfs, target_file)
    df === nothing && return false

    field_sym = field_name
    if !df_has_column(df, field_sym)
        return cond[:value] == ""
    end

    return _evaluate_cross_table_field_condition(df, field_sym, cond[:value])
end

function _evaluate_cross_table_field_condition(df, field_sym::Symbol, expected_value)
    column = df[!, field_sym]

    if expected_value == ""
        # True if all values are missing or empty
        return all(v -> ismissing(v) || string(v) == "", column)
    elseif expected_value == "defined"
        # True if any value is defined
        return any(v -> !ismissing(v) && string(v) != "", column)
    else
        # True if any value matches
        return any(v -> !ismissing(v) && string(v) == string(expected_value), column)
    end
end
