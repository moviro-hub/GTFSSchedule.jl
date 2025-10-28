"""
    Field Definitions Ingestion

Parses field definitions from the GTFS specification markdown.
Extracts field information including names, types, presence requirements, and descriptions.
"""

"""
    Field

Represents a single field definition from the GTFS specification.
"""
struct Field
    fieldname::String
    field_type::String
    presence::String
    description::String
end

"""
    FileFields

Represents a GTFS file definition with its fields and metadata.
"""
struct FileFields
    filename::String
    primary_key::String
    fields::Vector{Field}
end

"""
    parse_field_definitions(lines::Vector{String}) -> Vector{FileFields}

Parse field definitions from the "Field Definitions" section.
"""
function parse_field_definitions(lines::Vector{String})
    if isempty(lines)
        return FileFields[]
    end

    files = FileFields[]
    in_section = false
    current_file = nothing
    current_fields = Field[]
    current_primary_key = ""

    for (i, line) in enumerate(lines)
        stripped = strip(line)

        # Check for section start
        if is_header(line, "Field Definitions", 2)
            in_section = true
            continue
        end

        # Check for section end - only break on level 2 headers that are not Field Definitions
        if in_section && startswith(stripped, "## ") && !occursin("Field Definitions", stripped)
            break
        end

        if !in_section
            continue
        end

        # Check for new file definition
        if is_file_header(String(stripped))
            # Save previous file if it exists
            if current_file !== nothing && !isempty(current_fields)
                file_def = create_file_fields(current_file, current_fields, current_primary_key)
                push!(files, file_def)
            end

            # Start new file
            current_file = extract_filename(String(stripped))
            current_fields = Field[]
            current_primary_key = ""
            continue
        end

        # Extract primary key
        if current_file !== nothing && occursin("Primary key", stripped)
            primary_key_match = match(r"Primary key \(`([^`]+(?:`, `[^`]+)*)`\)", stripped)
            if primary_key_match !== nothing
                current_primary_key = String(primary_key_match[1])
            end
            continue
        end

        # Parse field table for current file
        if current_file !== nothing && isempty(current_fields)
            fields = parse_field_table(lines, i + 1)
            if !isempty(fields)
                current_fields = fields
            end
        end
    end

    # Add final file definition
    if current_file !== nothing && !isempty(current_fields)
        file_def = create_file_fields(current_file, current_fields, current_primary_key)
        push!(files, file_def)
    end

    return files
end

function is_file_header(line::String)
    if isempty(line)
        return false
    end
    return startswith(line, "### ") && (endswith(line, ".txt") || endswith(line, ".geojson"))
end

function extract_filename(header_line::String)
    return replace(header_line, "### " => "")
end

function create_file_fields(filename::String, fields::Vector{Field}, primary_key::String)
    return FileFields(filename, primary_key, fields)
end

function parse_field_table(lines::Vector{String}, start_line::Int)
    if isempty(lines) || start_line < 1 || start_line > length(lines)
        return Field[]
    end

    fields = Field[]
    table_header_found = false
    table_separator_found = false
    end_line = min(start_line + 50, length(lines))

    for i in start_line:end_line
        line = lines[i]
        stripped = strip(line)

        # Stop at next file definition
        if is_file_header(String(stripped))
            break
        end

        # Find table header
        if !table_header_found && is_field_table_header(String(stripped))
            table_header_found = true
            continue
        end

        # Find table separator
        if table_header_found && !table_separator_found && is_separator(String(stripped))
            table_separator_found = true
            continue
        end

        # Parse table rows
        if table_header_found && table_separator_found && startswith(stripped, "|")
            field = parse_field_row(line)
            if field !== nothing
                push!(fields, field)
            end
        end

        # Stop at end of table
        if table_header_found && table_separator_found && !isempty(fields) &&
                (isempty(stripped) || startswith(stripped, "###"))
            break
        end
    end

    return fields
end

function is_field_table_header(line::String)
    if isempty(line)
        return false
    end
    return occursin("Field Name", line) && (occursin("Type", line) || occursin("Presence", line))
end

function parse_field_row(line::String)
    if isempty(line)
        return nothing
    end

    parts = split(line, "|")
    cleaned_parts = [strip(part) for part in parts if !isempty(strip(part))]

    if length(cleaned_parts) < 3
        return nothing
    end

    fieldname = clean_name(cleaned_parts[1])
    field_type = cleaned_parts[2]
    presence = length(cleaned_parts) >= 3 ? cleaned_parts[3] : ""
    description = length(cleaned_parts) >= 4 ? cleaned_parts[4] : ""

    # Skip header and separator rows
    if is_header_or_sep(String(cleaned_parts[1]))
        return nothing
    end

    # Validate required fields
    if isempty(fieldname) || isempty(field_type)
        return nothing
    end

    # Set defaults for optional fields
    if isempty(presence)
        presence = "Unknown"
    else
        presence = strip_bold(presence)
    end

    if isempty(description)
        description = "No description available"
    end

    return Field(fieldname, field_type, presence, description)
end

function clean_name(field_name::AbstractString)
    return replace(String(field_name), "`" => "")
end
