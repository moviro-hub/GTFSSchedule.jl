"""
    Field Types Extraction

Extracts type information from GTFS specification field definitions.
Handles multiple types per field and maps them to primary and alternative types.
"""

"""
    FieldType

Represents type information for a single field.
"""
struct FieldType
    fieldname::String
    primary_type::String
    alternative_types::Vector{String}
end

"""
    FileTypes

Groups field type information by filename.
"""
struct FileTypes
    filename::String
    fields::Vector{FieldType}
end

"""
    extract_all_field_types(file_defs::Vector{FileFields}, field_types::Dict{String,String}, field_signs::Dict{String,String}) -> Vector{FileTypes}

Extract type information for all fields in all files.
"""
function extract_all_field_types(file_defs::Vector{FileFields}, field_types::Dict{String, String}, field_signs::Dict{String, String})
    if isempty(file_defs)
        return FileTypes[]
    end

    # Get all available types from ingested data
    available_types = collect(keys(field_types))

    result = FileTypes[]
    for file_def in file_defs
        # Skip non-txt files (e.g., .geojson) - but now we work with base names
        filename_lower = lowercase(file_def.filename)
        if !endswith(filename_lower, ".txt") && !endswith(filename_lower, ".geojson")
            continue
        end

        field_types = extract_field_types_for_file(file_def, available_types)
        file_info = FileTypes(strip_ext(file_def.filename), field_types)
        push!(result, file_info)
    end

    return result
end

function extract_field_types_for_file(file_def::FileFields, available_types::Vector{String})
    field_types = FieldType[]

    for field_def in file_def.fields
        # Parse the field type string
        primary_type, alternative_types = parse_type_string(field_def.field_type, available_types)

        # If no type found, use the original field type as fallback
        if primary_type === nothing
            primary_type = field_def.field_type
        end

        # Create field type info with cleaned field name
        field_info = FieldType(
            clean_name(field_def.fieldname),
            primary_type,
            alternative_types
        )

        push!(field_types, field_info)
    end

    return field_types
end

function parse_type_string(field_type_str::String, available_types::Vector{String})
    if isempty(field_type_str) || isempty(available_types)
        return (nothing, String[])
    end

    field_lower = lowercase(field_type_str)

    # Handle Foreign ID referencing pattern
    if occursin("foreign id referencing", field_lower)
        return ("ID", String[])
    end

    # Handle "or" pattern
    if occursin(" or ", field_lower)
        return parse_or_pattern(field_type_str, available_types)
    end

    # Try exact match for single type
    exact_match = find_exact_type_match(field_type_str, available_types)
    if exact_match !== nothing
        return (exact_match, String[])
    end

    # Try partial match
    partial_match = find_partial_type_match(field_type_str, available_types)
    if partial_match !== nothing
        return (partial_match, String[])
    end

    return (nothing, String[])
end

function parse_or_pattern(field_type_str::String, available_types::Vector{String})
    field_lower = lowercase(field_type_str)
    parts = split(field_lower, " or ")
    matched_types = String[]

    for part in parts
        part_cleaned = String(strip(part))
        if isempty(part_cleaned)
            continue
        end

        matched = find_exact_type_match(part_cleaned, available_types)
        if matched !== nothing
            push!(matched_types, matched)
        end
    end

    if isempty(matched_types)
        return (nothing, String[])
    end

    # First match is primary, rest are alternatives
    return (matched_types[1], matched_types[2:end])
end

function find_exact_type_match(type_str::String, available_types::Vector{String})
    if isempty(type_str) || isempty(available_types)
        return nothing
    end

    type_lower = lowercase(type_str)
    for available_type in available_types
        if lowercase(available_type) == type_lower
            return available_type
        end
    end
    return nothing
end

function find_partial_type_match(type_str::String, available_types::Vector{String})
    if isempty(type_str) || isempty(available_types)
        return nothing
    end

    type_lower = lowercase(type_str)
    # Sort by length (longest first) to prioritize more specific matches
    sorted_types = sort(available_types, by = length, rev = true)

    for available_type in sorted_types
        if occursin(lowercase(available_type), type_lower)
            return available_type
        end
    end
    return nothing
end
