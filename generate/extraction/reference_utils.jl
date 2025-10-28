"""
    Reference Utilities

Functions for extracting file and field references from GTFS specification text.
"""

function strip_ext(filename::AbstractString)
    return replace(String(filename), r"\.(txt|geojson)$" => "")
end

"""
    extract_file_refs(text::String) -> Vector{String}

Extract file references from GTFS specification text.
"""
function extract_file_refs(text::String)
    if isempty(text)
        return String[]
    end

    files = String[]

    # Extract markdown file links: [filename.txt](#filename)
    for match in eachmatch(r"\[([^\]]+\.(?:txt|geojson))\]\([^)]+\)", text)
        push!(files, strip_ext(match.captures[1]))
    end

    # Extract plain text file references: locations.geojson
    for match in eachmatch(r"\b([a-zA-Z_][a-zA-Z0-9_]*\.(?:txt|geojson))\b", text)
        push!(files, strip_ext(match.captures[1]))
    end

    return unique(files)
end

"""
    extract_field_refs(text::String) -> Vector{String}

Extract field references from backtick-wrapped text in GTFS specification.
"""
function extract_field_refs(text::String)
    if isempty(text)
        return String[]
    end

    fields = String[]

    for match in eachmatch(r"`([^`]+)`", text)
        push!(fields, match.captures[1])
    end

    return fields
end

"""
    is_valid_field(name::String) -> Bool

Validate that a field name is not just a number and contains at least one letter.
"""
function is_valid_field(name::String)
    # Must contain at least one letter and not be empty
    name_stripped = strip(name)
    return !isempty(name_stripped) && occursin(r"[a-zA-Z]", name)
end

"""
    clean_name(field_name::String) -> String

Clean up field names by removing HTML entities, whitespace, and formatting characters.
"""
function clean_name(field_name::String)
    if isempty(field_name)
        return ""
    end

    # Remove backticks (common in field names)
    cleaned = replace(field_name, "`" => "")

    # Remove HTML entities
    cleaned = replace(cleaned, "&nbsp;" => "")

    # Remove backslashes and dashes used for formatting
    cleaned = replace(cleaned, "\\-" => "")
    cleaned = replace(cleaned, "-" => "")

    # Remove leading/trailing whitespace and normalize internal whitespace
    cleaned = strip(cleaned)
    cleaned = replace(cleaned, r"\s+" => "_")  # Replace multiple spaces with underscore

    # Remove leading underscores that might result from cleaning
    cleaned = lstrip(cleaned, '_')

    return cleaned
end

"""
    clean_name(field_name::String, condition_file::String, target_file::String) -> String

Clean field name by removing table prefixes for same-file conditions.
"""
function clean_name(field_name::String, condition_file::String, target_file::String)
    # If condition references the same file, remove table prefix
    if condition_file == target_file && occursin(".", field_name)
        parts = split(field_name, ".")
        # Return last part if it matches the table name prefix
        if length(parts) >= 2
            return parts[end]
        end
    end
    return field_name
end

"""
    parse_field_ref(field_reference::String) -> Tuple{String, String}

Parse a field reference string to extract field name and value.
"""
function parse_field_ref(field_reference::String)
    if isempty(field_reference)
        return "", ""
    end

    # Handle "field=value" pattern
    if occursin("=", field_reference)
        field_parts = split(field_reference, "=")
        if length(field_parts) >= 2
            field_name = strip(field_parts[1])
            field_value = strip(field_parts[2])
            return field_name, field_value
        else
            return "", ""
        end
    end

    # Handle "field is defined" or "field is empty" patterns
    field_lower = lowercase(field_reference)
    if occursin(r"is\s+defined", field_lower)
        # Extract field name before "is defined"
        field_name = strip(replace(field_reference, r"(?i)\s+is\s+defined.*" => ""))
        return field_name, "defined"
    elseif occursin(r"is\s+empty", field_lower)
        # Extract field name before "is empty"
        field_name = strip(replace(field_reference, r"(?i)\s+is\s+empty.*" => ""))
        return field_name, ""
    end

    # Validate field name - must contain at least one letter
    if !is_valid_field(field_reference)
        return "", ""
    end

    # Default: just field name, no value
    return field_reference, ""
end

"""
    parse_file_field_ref(field_reference::String, current_file::String) -> Tuple{String, String}

Parse file and field names from a field reference.
"""
function parse_file_field_ref(field_reference::String, current_file::String)
    # Handle cross-file references (e.g., "stop_times.stop_id")
    if occursin(".", field_reference)
        parts = split(field_reference, ".")
        if length(parts) >= 2
            ref_file = strip_ext(parts[1])
            ref_field = parts[2]
            return ref_file, ref_field
        end
    end

    # Same-file reference
    return current_file, field_reference
end

"""
    build_field_map(file_definitions::Vector) -> Dict{String, String}

Build a mapping from field names to file names.
"""
function build_field_map(file_definitions::Vector)
    field_to_file = Dict{String, String}()

    for file_def in file_definitions
        for field in file_def.fields
            field_to_file[field.fieldname] = strip_ext(file_def.filename)
        end
    end

    return field_to_file
end

"""
    iterate_fields(file_definitions::Vector{FileFields})

Iterator that yields (file_def, field) pairs for all fields in all file definitions.
"""
function iterate_fields(file_definitions::Vector{FileFields})
    return ((file_def, field) for file_def in file_definitions for field in file_def.fields)
end
