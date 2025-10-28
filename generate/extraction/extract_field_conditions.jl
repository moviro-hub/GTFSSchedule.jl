"""
    Field Conditions Extraction

Extracts field-level conditional requirements from GTFS specification.
Handles "Conditionally Required" and "Conditionally Forbidden" field conditions.
"""

# =============================================================================
# DATA STRUCTURES
# =============================================================================

"""
    FieldCondition

Represents a condition that must be met for a field requirement.

# Fields
- `file::String`: The file containing the referenced field
- `field::String`: The field name being referenced
- `value::String`: The expected value or condition
- `same_file::Bool`: Whether the referenced field is in the same file
"""
struct FieldCondition
    file::String
    field::String
    value::String
    same_file::Bool
end

"""
    FieldRule

Represents a field's conditional requirement within a specific file.

# Fields
- `file::String`: The file containing this field
- `field::String`: The field name
- `presence::String`: The presence type (e.g., "Conditionally Required")
- `required::Bool`: Whether the field is required when conditions are met
- `forbidden::Bool`: Whether the field is forbidden when conditions are met
- `when_all_conditions::Vector{FieldCondition}`: Conditions that must all be true

# Logic
- `required=true, forbidden=false` → field is required when conditions are met
- `required=false, forbidden=true` → field is forbidden when conditions are met
- `required=false, forbidden=false` → field is optional
- Both `required` and `forbidden` true is invalid
"""
struct FieldRule
    file::String
    field::String
    presence::String
    required::Bool
    forbidden::Bool
    when_all_conditions::Vector{FieldCondition}
    forbidden_value::Union{String, Nothing}
end

"""
    FieldRules

Groups field rules by filename.

# Fields
- `filename::String`: The GTFS file name
- `fields::Vector{FieldRule}`: List of field rules for this file
"""
struct FieldRules
    filename::String
    fields::Vector{FieldRule}
end

# =============================================================================
# CONDITION SECTION EXTRACTION
# =============================================================================

"""
    extract_field_condition_section(description::String) -> String

Extract condition sections from field descriptions.

# Arguments
- `description::String`: Field description text

# Returns
- `String`: The condition section with HTML breaks normalized, or empty string if not found

# Examples
```julia
julia> extract_field_condition_section("Conditionally Required:<br>- When...")
"Conditionally Required:\n- When..."
```
"""
function extract_field_condition_section(description::String)
    if isempty(description)
        return ""
    end

    # Common condition section markers
    condition_markers = [
        "Conditionally Required:",
        "Conditionally Forbidden:",
        "**Conditionally Required**:",
        "**Conditionally Forbidden**:",
    ]

    return extract_condition_section(description, condition_markers)
end

# =============================================================================
# CONDITION PARSING
# =============================================================================

"""
    parse_field_level_condition_line(fieldname::String, line::String, current_file::String, presence::String) -> Union{FieldRule, Nothing}

Parse a single condition line for a field into a FieldRule.

# Arguments
- `fieldname::String`: The field name being processed
- `line::String`: The condition line text
- `current_file::String`: The current file being processed
- `presence::String`: The presence type (e.g., "Conditionally Required")

# Returns
- `Union{FieldRule, Nothing}`: Parsed field relation or nothing if parsing fails
"""
function parse_field_level_condition_line(fieldname::String, line::String, current_file::String, presence::String)
    if isempty(line) || isempty(fieldname)
        return nothing
    end

    # Parse requirement flags from the line text itself
    required, forbidden = parse_line_requirement_level(line, presence)

    # Skip Optional lines - they don't need validation rules
    if !required && !forbidden
        return nothing
    end

    # Special handling for conditional forbidden rules with specific value patterns
    # Pattern: `field=value` **forbidden** if `other_field` is defined
    if forbidden && occursin(r"`" * fieldname * r"=\d+`", line) && occursin("**forbidden**", line)
        relation = parse_value_specific_forbidden_rules(fieldname, line, current_file, presence)
        if relation !== nothing
            return relation
        end
    end

    # Extract field references from backticks
    field_references = extract_field_refs(line)
    if isempty(field_references)
        return nothing
    end

    # Parse each field reference into conditions
    conditions = FieldCondition[]
    for field_reference in field_references
        condition = parse_field_reference(field_reference, current_file, line)
        if condition !== nothing
            push!(conditions, condition)
        end
    end

    if isempty(conditions)
        return nothing
    end

    return FieldRule(current_file, fieldname, presence, required, forbidden, conditions, nothing)
end

"""
    parse_value_specific_forbidden_rules(fieldname::String, line::String, current_file::String, presence::String) -> Union{FieldRule, Nothing}

Parse conditional forbidden rules for fields with specific value patterns.
Pattern: `field=value` **forbidden** if `other_field` is defined.

# Arguments
- `fieldname::String`: The field name
- `line::String`: The condition line text
- `current_file::String`: The current file being processed
- `presence::String`: The presence type

# Returns
- `Union{FieldRule, Nothing}`: Parsed field relation or nothing if parsing fails
"""
function parse_value_specific_forbidden_rules(fieldname::String, line::String, current_file::String, presence::String)
    if isempty(line) || isempty(fieldname)
        return nothing
    end

    # Extract the forbidden value from the line (e.g., "pickup_type=0")
    value_match = match(r"`" * fieldname * r"=(\d+)`", line)
    if value_match === nothing
        return nothing
    end
    forbidden_value = value_match.captures[1]

    # Extract all field references from the line that are not the forbidden field itself
    all_field_references = extract_field_refs(line)
    condition_fields = String[]

    for field_ref in all_field_references
        # Skip the forbidden field itself (e.g., "pickup_type=0")
        if !occursin(fieldname * "=", field_ref)
            # Extract just the field name from the reference
            field_name = split(field_ref, "=")[1]
            if !isempty(field_name) && field_name != fieldname
                push!(condition_fields, field_name)
            end
        end
    end

    if isempty(condition_fields)
        return nothing
    end

    # Create separate rules for each condition field
    # This creates rules like: "pickup_type=0 is forbidden when start_pickup_drop_off_window is defined"
    all_relations = FieldRule[]

    for condition_field in condition_fields
        # Create a condition that checks for the window field being defined
        window_condition = FieldCondition(current_file, condition_field, "defined", true)

        # Create the field relation - the field is forbidden when the condition is met
        # We don't need to check the field's own value as that would be circular
        relation = FieldRule(current_file, fieldname, presence, false, true, [window_condition], forbidden_value)
        push!(all_relations, relation)
    end

    # Return the first relation (we'll handle multiple relations in the calling code)
    return isempty(all_relations) ? nothing : all_relations[1]
end


"""
    parse_field_reference(field_reference::String, current_file::String, line::String="") -> Union{FieldCondition, Nothing}

Parse a field reference string into a FieldCondition.

# Arguments
- `field_reference::String`: Field reference (e.g., "stop_id=1" or "routes.route_id")
- `current_file::String`: Current file context
- `line::String`: Full line context to check for "is defined" or "is empty" patterns

# Returns
- `Union{FieldCondition, Nothing}`: Parsed condition or nothing if invalid
"""
function parse_field_reference(field_reference::String, current_file::String, line::String = "")
    if isempty(field_reference)
        return nothing
    end

    # Parse field name and value, checking the line context for "is defined" or "is empty"
    ref_field, ref_value = parse_field_ref(field_reference)
    if isempty(ref_field)
        return nothing
    end

    # If no value was extracted from the field reference itself, check the line context
    if isempty(ref_value) && !isempty(line)
        # Look for "is defined" or "is empty" after the field reference in the line
        line_lower = lowercase(line)
        if occursin("`" * field_reference * "`", line)
            # Check what comes after this specific field reference
            after_field = split(line, "`" * field_reference * "`", limit = 2)
            if length(after_field) > 1
                after_text = lowercase(strip(after_field[2]))
                if occursin(r"^\s*(is|are)\s+defined", after_text)
                    ref_value = "defined"
                elseif occursin(r"^\s*(is|are)\s+empty", after_text)
                    ref_value = ""
                elseif occursin(r"^\s*(is|are)\s+NOT\s+defined", after_text)
                    ref_value = ""
                elseif occursin(r"^\s*and\s+.*\s+are\s+NOT\s+defined", after_text)
                    ref_value = ""
                end
            end
        end

        # Also check for "is/are defined" pattern that might come after "or" in the sentence
        if isempty(ref_value) && (occursin("is defined", line_lower) || occursin("are defined", line_lower))
            # Look for the field reference followed by "or" and then "is/are defined"
            # Use a more flexible approach to handle the "or" condition
            if occursin("`" * field_reference * "`", line_lower) &&
                    occursin("or", line_lower) &&
                    (occursin("is defined", line_lower) || occursin("are defined", line_lower))
                ref_value = "defined"
            end
        end

        # Check for "is/are NOT defined" pattern that might come after "or" in the sentence
        if isempty(ref_value) && (occursin("is NOT defined", line_lower) || occursin("are NOT defined", line_lower))
            # Look for the field reference followed by "or" and then "is/are NOT defined"
            if occursin("`" * field_reference * "`", line_lower) &&
                    occursin("or", line_lower) &&
                    (occursin("is NOT defined", line_lower) || occursin("are NOT defined", line_lower))
                ref_value = ""
            end
        end
    end

    # Parse file and field names
    ref_file, _ = parse_file_field_ref(field_reference, current_file)

    # Clean field name - remove table prefixes for same-file conditions
    ref_field = clean_name(String(ref_field), ref_file, current_file)

    same_file = (ref_file == current_file)
    return FieldCondition(ref_file, ref_field, ref_value, same_file)
end


# =============================================================================
# MAIN EXTRACTION FUNCTIONS
# =============================================================================

"""
    parse_field_level_conditional_requirements(file_def::FileFields, conditionally_required::String, conditionally_forbidden::String) -> Vector{FieldRule}

Parse field-level conditional requirements for all fields in a file definition.

# Arguments
- `file_def::FileFields`: File definition containing fields to process
- `conditionally_required::String`: Presence type for conditionally required fields
- `conditionally_forbidden::String`: Presence type for conditionally forbidden fields

# Returns
- `Vector{FieldRule}`: List of field relations with conditional requirements
"""
function parse_field_level_conditional_requirements(file_def::FileFields, conditionally_required::String, conditionally_forbidden::String)
    field_requirements = FieldRule[]

    for field in file_def.fields
        # Only process fields with conditional presence
        if !(field.presence in [conditionally_required, conditionally_forbidden])
            continue
        end

        section = extract_field_condition_section(field.description)
        if isempty(section)
            continue
        end

        # Parse condition lines
        condition_lines = parse_condition_lines(section)
        for line in condition_lines
            field_relation = parse_field_level_condition_line(field.fieldname, line, strip_ext(file_def.filename), field.presence)
            if field_relation !== nothing
                # Check if this is an "or" condition that needs to be split
                if length(field_relation.when_all_conditions) > 1 && occursin(" or ", lowercase(line))
                    # Split into separate rules for each condition
                    for condition in field_relation.when_all_conditions
                        split_relation = FieldRule(
                            strip_ext(field_relation.file),
                            field_relation.field,
                            field_relation.presence,
                            field_relation.required,
                            field_relation.forbidden,
                            [condition],
                            field_relation.forbidden_value
                        )
                        push!(field_requirements, split_relation)
                    end
                else
                    push!(field_requirements, field_relation)
                end
            end
        end
    end

    return field_requirements
end


"""
    extract_all_field_conditions(file_definitions::Vector{FileFields}, presence_types::Vector=Presence[]) -> Vector{FieldRules}

Extract field-level conditional requirements for all files.

# Arguments
- `file_definitions::Vector{FileFields}`: List of file definitions to process
- `presence_types::Vector=Presence[]`: List of presence types for validation

# Returns
- `Vector{FieldRules}`: List of field relations grouped by file
"""
function extract_all_field_conditions(file_definitions::Vector{FileFields}, presence_types::Vector = Presence[])
    if isempty(file_definitions)
        return FieldRules[]
    end

    # Get presence keywords for validation
    conditionally_required = "Conditionally Required"
    conditionally_forbidden = "Conditionally Forbidden"

    if !isempty(presence_types)
        for presence_info in presence_types
            if presence_info.presence == "Conditionally Required"
                conditionally_required = presence_info.presence
            elseif presence_info.presence == "Conditionally Forbidden"
                conditionally_forbidden = presence_info.presence
            end
        end
    end

    result = FieldRules[]

    for file_def in file_definitions
        field_requirements = parse_field_level_conditional_requirements(file_def, conditionally_required, conditionally_forbidden)
        if !isempty(field_requirements)
            push!(result, FieldRules(strip_ext(file_def.filename), field_requirements))
        end
    end

    return result
end
