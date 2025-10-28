"""
    Field Enum Values Extraction

Extracts enum values and their descriptions from GTFS specification field definitions.
Handles various enum formats including "empty" values and value mappings.
"""

# =============================================================================
# DATA STRUCTURES
# =============================================================================

"""
    EnumValue

Represents a single enum value with its description.

# Fields
- `value::String`: The enum value as string (e.g., "0", "1", "empty")
- `description::String`: Human-readable description (e.g., "Tram, Streetcar, Light rail")
"""
struct EnumValue
    value::String
    description::String
end

"""
    FieldEnum

Represents enum information for a single field.

# Fields
- `field::String`: The field name (e.g., "route_type")
- `enum_values::Vector{EnumValue}`: List of possible enum values
- `allow_empty::Bool`: Whether "empty" is listed as a valid option
- `empty_maps_to::Union{Nothing,String}`: If "X or empty" appears, maps empty to X
"""
struct FieldEnum
    field::String
    enum_values::Vector{EnumValue}
    allow_empty::Bool
    empty_maps_to::Union{Nothing, String}
end

"""
    FileEnums

Groups enum field information by filename.

# Fields
- `filename::String`: The GTFS file name
- `fields::Vector{FieldEnum}`: List of enum field information for this file
"""
struct FileEnums
    filename::String
    fields::Vector{FieldEnum}
end

# =============================================================================
# ENUM SECTION EXTRACTION
# =============================================================================

"""
    extract_enum_section(description::String) -> String

Extract the enum section from field description text.

# Arguments
- `description::String`: Field description text

# Returns
- `String`: The enum section with HTML breaks normalized, or empty string if not found

# Examples
```julia
julia> extract_enum_section("Valid options are:<br>- 0: Tram")
"Valid options are:\n- 0: Tram"
```
"""
function extract_enum_section(description::String)
    if isempty(description)
        return ""
    end

    # Common enum section markers
    enum_markers = [
        "Valid options are:",
        "Valid values are:",
        "The following values are supported:",
        "Allowed values:",
    ]

    return extract_condition_section(description, enum_markers)
end

# =============================================================================
# ENUM LINE PARSING
# =============================================================================

"""
    parse_enum_line(line::String) -> Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}

Parse a single enum item line into an enum value and metadata.

# Arguments
- `line::String`: The enum line to parse

# Returns
- `Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}`:
  (enum_value, allow_empty, empty_maps_to)

# Examples
```julia
julia> parse_enum_line("- 0 - Tram, Streetcar, Light rail")
(EnumValue("0", "Tram, Streetcar, Light rail"), false, nothing)

julia> parse_enum_line("- 0 (or empty) - Tram, Streetcar, Light rail")
(EnumValue("0", "Tram, Streetcar, Light rail"), true, "0")
```
"""
function parse_enum_line(line::String)
    if isempty(line)
        return (nothing, false, nothing)
    end

    # Normalize the line
    normalized_line = normalize_enum_line(line)

    # Try different parsing patterns
    result = try_parse_backtick_pattern(normalized_line)
    if result !== nothing
        return result
    end

    result = try_parse_plain_pattern(normalized_line)
    if result !== nothing
        return result
    end

    result = try_parse_empty_or_pattern(normalized_line)
    if result !== nothing
        return result
    end

    result = try_parse_empty_standalone_pattern(normalized_line)
    if result !== nothing
        return result
    end

    # No pattern matched
    return (nothing, false, nothing)
end

"""
    normalize_enum_line(line::String) -> String

Normalize an enum line by removing bullet markers and extra whitespace.

# Arguments
- `line::String`: The original line

# Returns
- `String`: Normalized line
"""
function normalize_enum_line(line::String)
    # Remove bullet markers and normalize whitespace
    normalized = replace(line, r"^\s*[-\*•]\s*" => "")
    return String(strip(normalized))
end

"""
    try_parse_backtick_pattern(line::String) -> Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}

Try to parse a backtick-wrapped enum pattern.

# Arguments
- `line::String`: The normalized line

# Returns
- `Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}`: Parsed result or nothing
"""
function try_parse_backtick_pattern(line::String)
    # Pattern: `value` (or empty) - Description
    backtick_pattern = r"`([^`]+)`\s*(?:(?:\(\s*or\s*empty\s*\))|(?:or\s*empty))?\s*[-–:]\s*(.+)"

    match_result = match(backtick_pattern, line)
    if match_result === nothing
        return nothing
    end

    raw_value = String(strip(match_result.captures[1]))
    description = clean_description(String(strip(match_result.captures[2])))

    # Handle empty values
    if lowercase(raw_value) == "empty"
        return (nothing, true, nothing)
    end

    # Check for empty mapping
    has_empty = occursin(r"(?i)empty", line)
    empty_maps_to = has_empty ? raw_value : nothing

    # Clean up "(or empty)" from the value if present
    if (empty_match = match(r"\(\s*or\s*empty\s*\)", raw_value)) !== nothing
        has_empty = true
        raw_value = strip(replace(raw_value, empty_match.match => ""))
        empty_maps_to = raw_value
    end

    return (EnumValue(raw_value, description), has_empty, empty_maps_to)
end

"""
    try_parse_plain_pattern(line::String) -> Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}

Try to parse a plain numeric enum pattern.

# Arguments
- `line::String`: The normalized line

# Returns
- `Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}`: Parsed result or nothing
"""
function try_parse_plain_pattern(line::String)
    # Pattern: 0 (or empty) - Description
    plain_pattern = r"^\s*(-?\d+)\s*(?:\(\s*or\s*empty\s*\)|\s*or\s*empty)?\s*[-–:]\s*(.+)"

    match_result = match(plain_pattern, line)
    if match_result === nothing
        return nothing
    end

    raw_value = String(strip(match_result.captures[1]))
    description = clean_description(String(strip(match_result.captures[2])))
    has_empty = occursin(r"(?i)empty", line)
    empty_maps_to = has_empty ? raw_value : nothing

    return (EnumValue(raw_value, description), has_empty, empty_maps_to)
end

"""
    try_parse_empty_or_pattern(line::String) -> Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}

Try to parse an "empty or X" enum pattern.

# Arguments
- `line::String`: The normalized line

# Returns
- `Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}`: Parsed result or nothing
"""
function try_parse_empty_or_pattern(line::String)
    # Pattern: empty or 0 - Description
    empty_or_pattern = r"^(?i:empty)\s*or\s*(-?\d+)\s*[-–:]\s*(.+)"

    match_result = match(empty_or_pattern, line)
    if match_result === nothing
        return nothing
    end

    raw_value = String(strip(match_result.captures[1]))
    description = clean_description(String(strip(match_result.captures[2])))

    return (EnumValue(raw_value, description), true, raw_value)
end

"""
    try_parse_empty_standalone_pattern(line::String) -> Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}

Try to parse an "empty - Description" enum pattern.

# Arguments
- `line::String`: The normalized line

# Returns
- `Union{Tuple{Union{EnumValue, Nothing}, Bool, Union{Nothing, String}}, Nothing}`: Parsed result or nothing
"""
function try_parse_empty_standalone_pattern(line::String)
    # Pattern: empty - Description
    empty_standalone_pattern = r"^(?i:empty)\s*[-–:]\s*(.+)"

    match_result = match(empty_standalone_pattern, line)
    if match_result === nothing
        return nothing
    end

    description = clean_description(String(strip(match_result.captures[1])))

    return (nothing, true, nothing)
end

"""
    clean_description(description::String) -> String

Clean up enum description text by removing trailing punctuation and whitespace.

# Arguments
- `description::String`: The raw description text

# Returns
- `String`: Cleaned description
"""
function clean_description(description::String)
    return strip(description, ['.', ' ', '\n', '\r'])
end

# =============================================================================
# MAIN EXTRACTION FUNCTIONS
# =============================================================================

"""
    parse_enum_field(field::Field) -> Union{FieldEnum, Nothing}

Parse a field definition into a FieldEnum if it contains enum values.

# Arguments
- `field::Field`: The field definition to parse

# Returns
- `Union{FieldEnum, Nothing}`: Parsed enum field or nothing if not an enum field
"""
function parse_enum_field(field::Field)
    if field.field_type != "Enum"
        return nothing
    end

    section = extract_enum_section(field.description)
    if isempty(section)
        return nothing
    end

    # Parse enum values from section
    enum_values, section_allow_empty, empty_maps_to = parse_enum_section_values(section)

    if isempty(enum_values)
        return nothing
    end

    # Determine allow_empty based on field presence
    # Optional, Conditionally Required, and Conditionally Forbidden fields should allow empty values
    # because the field might not be required/forbidden in all cases
    # Only strictly Required fields should not allow empty values (unless specified in description)
    allow_empty = (field.presence != "Required") || section_allow_empty

    # Clean field name
    cleaned_field_name = clean_name(field.fieldname)
    return FieldEnum(cleaned_field_name, enum_values, allow_empty, empty_maps_to)
end

"""
    parse_enum_section_values(section::String) -> Tuple{Vector{EnumValue}, Bool, Union{Nothing, String}}

Parse enum values from a section of text.

# Arguments
- `section::String`: The enum section text

# Returns
- `Tuple{Vector{EnumValue}, Bool, Union{Nothing, String}}`:
  (enum_values, allow_empty, empty_maps_to)
"""
function parse_enum_section_values(section::String)
    enum_values = EnumValue[]
    allow_empty = false
    empty_maps_to = nothing

    for line in split(section, '\n')
        line_stripped = String(strip(line))
        if isempty(line_stripped)
            continue
        end

        enum_val, line_allow_empty, line_empty_maps_to = parse_enum_line(line_stripped)
        if enum_val !== nothing
            push!(enum_values, enum_val)
        end

        allow_empty = allow_empty || line_allow_empty
        if line_empty_maps_to !== nothing
            empty_maps_to = line_empty_maps_to
        end
    end

    return enum_values, allow_empty, empty_maps_to
end


"""
    extract_all_field_enum_values(file_definitions::Vector{FileFields}) -> Vector{FileEnums}

Extract enum values for all fields in all file definitions, grouped by file.

# Arguments
- `file_definitions::Vector{FileFields}`: List of file definitions to process

# Returns
- `Vector{FileEnums}`: List of file enum information grouped by file
"""
function extract_all_field_enum_values(file_definitions::Vector{FileFields})
    if isempty(file_definitions)
        return FileEnums[]
    end

    result = FileEnums[]
    for file_def in file_definitions
        # Skip non-txt files (e.g., .geojson) - but now we work with base names
        if !endswith(lowercase(file_def.filename), ".txt") && !endswith(lowercase(file_def.filename), ".geojson")
            continue
        end

        field_enums = FieldEnum[]
        for field in file_def.fields
            enum_field = parse_enum_field(field)
            if enum_field !== nothing
                push!(field_enums, enum_field)
            end
        end

        if !isempty(field_enums)
            file_enum_info = FileEnums(strip_ext(file_def.filename), field_enums)
            push!(result, file_enum_info)
        end
    end

    return result
end
