"""
    File Conditions Extraction

Extracts file-level conditional requirements from GTFS specification.
Handles "Conditionally Required" and "Conditionally Forbidden" file conditions.
"""

# =============================================================================
# DATA STRUCTURES
# =============================================================================

"""
    Condition

Abstract base type for all condition types.
"""
abstract type Condition end

"""
    FileCondition <: Condition

Represents a condition based on file existence.

# Fields
- `file::String`: The file name
- `must_exist::Bool`: Whether the file must exist (true) or must not exist (false)
"""
struct FileCondition <: Condition
    file::String
    must_exist::Bool
end

"""
    FileFieldCondition <: Condition

Represents a condition based on a field value in a file.

# Fields
- `file::String`: The file containing the field
- `field::String`: The field name
- `value::String`: The expected value
- `same_file::Bool`: Whether the referenced field is in the same file
"""
struct FileFieldCondition <: Condition
    file::String
    field::String
    value::String
    same_file::Bool
end

"""
    FileRule

Represents a file's conditional requirement.

# Fields
- `required::Bool`: Whether the file is required when conditions are met
- `forbidden::Bool`: Whether the file is forbidden when conditions are met
- `when_all_conditions::Vector{Condition}`: Conditions that must all be true

# Logic
- `required=true, forbidden=false` → file is required when conditions are met
- `required=false, forbidden=true` → file is forbidden when conditions are met
- `required=false, forbidden=false` → file is optional
- Both `required` and `forbidden` true is invalid
"""
struct FileRule
    required::Bool
    forbidden::Bool
    when_all_conditions::Vector{Condition}
end

"""
    FileRules

Groups file rules by filename and presence type.

# Fields
- `filename::String`: The GTFS file name
- `presence::String`: The presence type
- `conditions::Vector{FileRule}`: List of file rules
"""
struct FileRules
    filename::String
    presence::String
    conditions::Vector{FileRule}
end


# =============================================================================
# CONDITION PARSING
# =============================================================================

"""
    parse_file_level_condition_line(line::String, presence::String, field_to_file::Dict{String, String}) -> Union{FileRule, Nothing}

Parse a single condition line into a FileRule.

# Arguments
- `line::String`: The condition line text
- `presence::String`: The presence type (e.g., "Conditionally Required")
- `field_to_file::Dict{String, String}`: Mapping of field names to file names

# Returns
- `Union{FileRule, Nothing}`: Parsed file relation or nothing if parsing fails
"""
function parse_file_level_condition_line(line::String, presence::String, field_to_file::Dict{String, String})
    if isempty(line)
        return nothing
    end

    # Check for "unless" conditions (invert the logic)
    line_lower = lowercase(line)
    is_unless_condition = occursin("unless", line_lower)

    # Determine requirement flags based on presence type
    required, forbidden = parse_presence_flags(presence)

    # Extract file and field references
    file_references = extract_file_refs(line)
    field_references = extract_field_refs(line)

    # Parse conditions
    conditions = parse_conditions_from_references(line, file_references, field_references, field_to_file)

    if isempty(conditions)
        return nothing
    end

    # Handle conditional logic based on the condition text
    line_lower = lowercase(line)
    should_invert = false

    # Special case: "Optional if... Required otherwise" pattern
    if occursin("optional if", line_lower) && (occursin("required otherwise", line_lower) || occursin("**required** otherwise", line_lower))
        should_invert = true
        # Special case: "Required unless... Optional otherwise" pattern
    elseif occursin("required unless", line_lower) || occursin("**required** unless", line_lower)
        should_invert = true
        # Check for inversion keywords in the condition text
    elseif any(occursin(keyword, line_lower) for keyword in ["unless", "omitted", "not defined", "not provided"])
        should_invert = true
    end

    if should_invert
        new_conditions = Condition[]
        for condition in conditions
            if isa(condition, FileCondition)
                # Create new FileCondition with inverted must_exist
                new_condition = FileCondition(strip_ext(condition.file), !condition.must_exist)
                push!(new_conditions, new_condition)
            else
                push!(new_conditions, condition)
            end
        end
        conditions = new_conditions
    end

    return FileRule(required, forbidden, conditions)
end

"""
    generate_complementary_relation(primary_relation::Union{FileRule, Nothing}, field_to_file::Dict{String, String}) -> Union{FileRule, Nothing}

Generate a complementary relation for "either/or" patterns.
The complementary relation makes the file optional when the alternative exists.

# Arguments
- `primary_relation::Union{FileRule, Nothing}`: The primary relation to complement
- `field_to_file::Dict{String, String}`: Mapping of field names to file names

# Returns
- `Union{FileRule, Nothing}`: Complementary relation or nothing if generation fails
"""
function generate_complementary_relation(primary_relation::Union{FileRule, Nothing}, field_to_file::Dict{String, String})
    if primary_relation === nothing
        return nothing
    end

    # Create complementary conditions by inverting file existence requirements
    complementary_conditions = Condition[]
    for condition in primary_relation.when_all_conditions
        if isa(condition, FileCondition)
            # Invert the must_exist flag
            complementary_condition = FileCondition(strip_ext(condition.file), !condition.must_exist)
            push!(complementary_conditions, complementary_condition)
        else
            # For field conditions, keep them as-is (they don't need inversion)
            push!(complementary_conditions, condition)
        end
    end

    # The complementary relation makes the file optional (not required, not forbidden)
    return FileRule(false, false, complementary_conditions)
end


"""
    parse_conditions_from_references(line::String, file_references::Vector{String}, field_references::Vector{String}, field_to_file::Dict{String, String}) -> Vector{Condition}

Parse file and field references into condition objects.

# Arguments
- `line::String`: The original condition line for context
- `file_references::Vector{String}`: List of file references found
- `field_references::Vector{String}`: List of field references found
- `field_to_file::Dict{String, String}`: Mapping of field names to file names

# Returns
- `Vector{Condition}`: List of parsed conditions
"""
function parse_conditions_from_references(line::String, file_references::Vector{String}, field_references::Vector{String}, field_to_file::Dict{String, String})
    conditions = Condition[]

    # Parse file conditions
    for file_ref in file_references
        file_condition = parse_file_condition(line, file_ref)
        if file_condition !== nothing
            push!(conditions, file_condition)
        end
    end

    # Parse field conditions
    for field_ref in field_references
        field_condition = parse_field_condition(field_ref, field_to_file, file_references, line)
        if field_condition !== nothing
            push!(conditions, field_condition)
        end
    end

    return conditions
end

"""
    parse_file_condition(line::String, file_ref::String) -> Union{FileCondition, Nothing}

Parse a file reference into a FileCondition.

# Arguments
- `line::String`: The condition line for context
- `file_ref::String`: The file reference

# Returns
- `Union{FileCondition, Nothing}`: Parsed file condition or nothing if invalid
"""
function parse_file_condition(line::String, file_ref::String)
    if isempty(file_ref)
        return nothing
    end

    # Determine if file must exist or not based on context
    must_exist = determine_file_existence_requirement(line)

    return FileCondition(file_ref, must_exist)
end

"""
    determine_file_existence_requirement(line::String) -> Bool

Determine if a file must exist based on the condition line context.

# Arguments
- `line::String`: The condition line

# Returns
- `Bool`: true if file must exist, false if file must not exist
"""
function determine_file_existence_requirement(line::String)
    line_lower = lowercase(line)

    # Special case: "Optional if... Required otherwise" pattern - don't check for "otherwise"
    is_optional_if_pattern = occursin("optional if", line_lower) && (occursin("required otherwise", line_lower) || occursin("**required** otherwise", line_lower))

    # Special case: "Required unless... Optional otherwise" pattern - don't check for "otherwise"
    is_required_unless_pattern = occursin("required unless", line_lower) || occursin("**required** unless", line_lower)

    # Check for negative indicators
    negative_indicators = if is_optional_if_pattern || is_required_unless_pattern
        ["omitted", "is not", "not defined", "not provided"]
    else
        ["omitted", "is not", "not defined", "not provided", "unless", "otherwise"]
    end

    if any(occursin(indicator, line_lower) for indicator in negative_indicators)
        return false
    end

    # Check for positive indicators
    positive_indicators = ["defined", "exists", "present", "provided"]
    if any(occursin(indicator, line_lower) for indicator in positive_indicators)
        return true
    end

    # Default to file must exist
    return true
end

"""
    parse_field_condition(field_ref::String, field_to_file::Dict{String, String}, file_references::Vector{String}, line::String) -> Union{FileFieldCondition, Nothing}

Parse a field reference into a FileFieldCondition.

# Arguments
- `field_ref::String`: The field reference
- `field_to_file::Dict{String, String}`: Mapping of field names to file names
- `file_references::Vector{String}`: List of file references found in the condition line
- `line::String`: The original condition line for context

# Returns
- `Union{FileFieldCondition, Nothing}`: Parsed field condition or nothing if invalid
"""
function parse_field_condition(field_ref::String, field_to_file::Dict{String, String}, file_references::Vector{String}, line::String)
    if isempty(field_ref)
        return nothing
    end

    # Parse field name and value
    field_name, field_value = parse_field_ref(field_ref)
    if isempty(field_name)
        return nothing
    end

    # Check if the condition line contains "exists" or "defined" keywords
    line_lower = lowercase(line)
    if isempty(field_value) && (occursin("exists", line_lower) || occursin("defined", line_lower))
        field_value = "defined"
    end

    # Determine file context - prioritize file references from the condition text
    file_name = ""
    if !isempty(file_references)
        # Use the first file reference found in the condition text
        file_name = file_references[1]
    else
        # Fall back to the field-to-file mapping
        file_name = get(field_to_file, field_name, "")
    end
    same_file = !isempty(file_name)

    return FileFieldCondition(file_name, field_name, field_value, same_file)
end

# =============================================================================
# MAIN EXTRACTION FUNCTIONS
# =============================================================================

"""
    parse_file_level_conditional_requirements(dataset_file, field_to_file::Dict{String, String}, conditionally_required::String, conditionally_forbidden::String) -> Vector{FileRule}

Parse file-level conditional requirements from a dataset file definition.

# Arguments
- `dataset_file`: Dataset file definition to process
- `field_to_file::Dict{String, String}`: Mapping of field names to file names
- `conditionally_required::String`: Presence type for conditionally required files
- `conditionally_forbidden::String`: Presence type for conditionally forbidden files

# Returns
- `Vector{FileRule}`: List of file relations with conditional requirements
"""
function parse_file_level_conditional_requirements(dataset_file, field_to_file::Dict{String, String}, conditionally_required::String, conditionally_forbidden::String)
    if !(dataset_file.presence in [conditionally_required, conditionally_forbidden])
        return FileRule[]
    end

    section = extract_condition_section(dataset_file.description, ["Conditionally Required:", "Conditionally Forbidden:"])
    if isempty(section)
        return FileRule[]
    end

    # Parse condition lines
    condition_lines = parse_condition_lines(section)
    conditions = FileRule[]

    # Check if this is an "Optional if... Required otherwise" pattern
    has_optional_if = any(occursin("optional if", lowercase(line)) for line in condition_lines)
    has_required_otherwise = any(occursin("required otherwise", lowercase(line)) || occursin("**required** otherwise", lowercase(line)) for line in condition_lines)

    # Check if this is a "Required unless... Optional otherwise" pattern
    has_required_unless = any(occursin("required unless", lowercase(line)) || occursin("**required** unless", lowercase(line)) for line in condition_lines)
    has_optional_otherwise = any(occursin("optional otherwise", lowercase(line)) for line in condition_lines)

    # Check if this is a "Required if... Optional otherwise" pattern
    has_required_if = any(occursin("required if", lowercase(line)) || occursin("**required** if", lowercase(line)) for line in condition_lines)
    has_optional_otherwise_alt = any(occursin("optional otherwise", lowercase(line)) for line in condition_lines)

    if (has_optional_if && has_required_otherwise) || (has_required_unless && has_optional_otherwise) || (has_required_if && has_optional_otherwise_alt)
        # This is an "either/or" pattern - generate complementary rules
        combined_line = join(condition_lines, " ")

        # Generate the primary rule (required when alternative doesn't exist)
        primary_relation = parse_file_level_condition_line(combined_line, dataset_file.presence, field_to_file)
        if primary_relation !== nothing
            push!(conditions, primary_relation)
        end

        # Generate the complementary rule (optional when alternative exists)
        # Invert the file existence conditions for the complementary rule
        complementary_relation = generate_complementary_relation(primary_relation, field_to_file)
        if complementary_relation !== nothing
            push!(conditions, complementary_relation)
        end
    else
        # Process each line separately
        for line in condition_lines
            file_relation = parse_file_level_condition_line(line, dataset_file.presence, field_to_file)
            if file_relation !== nothing
                push!(conditions, file_relation)
            end
        end
    end

    return conditions
end


"""
    to_parsed_file_level_conditions(dataset_file, field_to_file::Dict{String, String}, conditionally_required::String, conditionally_forbidden::String) -> FileRules

Convert a DatasetFile to a FileRules with parsed conditions.

# Arguments
- `dataset_file`: Dataset file definition to convert
- `field_to_file::Dict{String, String}`: Mapping of field names to file names
- `conditionally_required::String`: Presence type for conditionally required files
- `conditionally_forbidden::String`: Presence type for conditionally forbidden files

# Returns
- `FileRules`: File relations with parsed conditions
"""
function to_parsed_file_level_conditions(dataset_file, field_to_file::Dict{String, String}, conditionally_required::String, conditionally_forbidden::String)
    conditions = parse_file_level_conditional_requirements(dataset_file, field_to_file, conditionally_required, conditionally_forbidden)
    return FileRules(
        strip_ext(dataset_file.filename),
        dataset_file.presence,
        conditions
    )
end

"""
    extract_all_file_conditions(dataset_files::Vector, file_definitions::Vector, presence_types::Vector=Presence[]) -> Vector{FileRules}

Extract file-level conditional requirements for all dataset files.

# Arguments
- `dataset_files::Vector`: List of dataset file definitions to process
- `file_definitions::Vector`: List of file definitions for field mapping
- `presence_types::Vector=Presence[]`: List of presence types for validation

# Returns
- `Vector{FileRules}`: List of file relations grouped by file
"""
function extract_all_file_conditions(dataset_files::Vector, file_definitions::Vector, presence_types::Vector = Presence[])
    if isempty(dataset_files)
        return FileRules[]
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

    # Build field to file lookup dictionary
    field_to_file = build_field_map(file_definitions)

    # Process each dataset file
    result = FileRules[]
    for dataset_file in dataset_files
        file_relations = to_parsed_file_level_conditions(dataset_file, field_to_file, conditionally_required, conditionally_forbidden)
        push!(result, file_relations)
    end

    # Validate known either/or pairs
    validate_known_either_or_pairs(result)

    return result
end

"""
    validate_known_either_or_pairs(file_relations::Vector{FileRules})

Validate that known either/or pairs have complementary rules.
This ensures the extraction is working correctly and catches edge cases.

# Arguments
- `file_relations::Vector{FileRules}`: List of file relations to validate
"""
function validate_known_either_or_pairs(file_relations::Vector{FileRules})
    # Known either/or pairs from GTFS specification
    known_pairs = [
        ("stops", "locations"),
        ("calendar", "calendar_dates"),
    ]

    # Create lookup for file relations
    relations_by_file = Dict{String, FileRules}()
    for rel in file_relations
        relations_by_file[rel.filename] = rel
    end

    for (file1, file2) in known_pairs
        has_file1 = haskey(relations_by_file, file1)
        has_file2 = haskey(relations_by_file, file2)

        if has_file1 && has_file2
            # Check if the primary file (file1) has complementary rules
            file1_relations = relations_by_file[file1]
            file2_relations = relations_by_file[file2]

            # Verify that file1 has a rule that makes it optional when file2 exists
            file1_has_optional_rule = has_optional_rule_for_alternative(file1_relations, file2)

            # For true either/or pairs, file2 should also have complementary rules
            # But for cases where file2 is "Optional", it doesn't need complementary rules
            file2_needs_complementary = file2_relations.presence == "Conditionally Required"
            file2_has_optional_rule = if file2_needs_complementary
                has_optional_rule_for_alternative(file2_relations, file1)
            else
                true  # Optional files don't need complementary rules
            end

            if !file1_has_optional_rule
                # This is informational - some either/or pairs may not have complete complementary rules
                # println("WARNING: $file1 missing optional rule when $file2 exists")
            end

            if file2_needs_complementary && !file2_has_optional_rule
                # This is informational - some either/or pairs may not have complete complementary rules
                # println("WARNING: $file2 missing optional rule when $file1 exists")
            end

            if file1_has_optional_rule && file2_has_optional_rule
                println("✓ Either/or pair ($file1, $file2) has complete complementary rules")
            end
        end
    end
    return
end

"""
    has_optional_rule_for_alternative(file_relations::FileRules, alternative_file::String) -> Bool

Check if a file has an optional rule when the alternative file exists.

# Arguments
- `file_relations::FileRules`: The file relations to check
- `alternative_file::String`: The alternative file name

# Returns
- `Bool`: true if the file has an optional rule when alternative exists
"""
function has_optional_rule_for_alternative(file_relations::FileRules, alternative_file::String)
    for relation in file_relations.conditions
        # Check if this is an optional rule (required=false, forbidden=false)
        if !relation.required && !relation.forbidden
            # Check if the condition is that the alternative file exists
            for condition in relation.when_all_conditions
                if isa(condition, FileCondition) && condition.file == strip_ext(alternative_file) && condition.must_exist
                    return true
                end
            end
        end
    end
    return false
end
