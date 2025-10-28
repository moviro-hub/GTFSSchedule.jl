"""
    Table Utilities

Functions for parsing markdown tables in GTFS specification content.
"""

const TABLE_HEADER_PATTERNS = [
    "Field Name", "File Name", "Type", "Presence", "Description",
]

"""
    find_markdown_table(lines::Vector{String}, start_idx::Int, max_lookahead::Int) -> Union{Tuple{Int, Int}, Nothing}

Find the start of a markdown table (header and separator).
"""
function find_table(lines::Vector{String}, start_idx::Int, max_lookahead::Int)
    if isempty(lines) || start_idx < 1 || start_idx > length(lines)
        return nothing
    end

    header_idx = nothing
    separator_idx = nothing
    end_idx = min(start_idx + max_lookahead, length(lines))

    for i in start_idx:end_idx
        stripped = strip(lines[i])

        # Look for header line (starts with | and contains another |)
        if header_idx === nothing && is_header(String(stripped))
            header_idx = i
            continue
        end

        # Look for separator line (starts with |-- or contains ---)
        if header_idx !== nothing && separator_idx === nothing && is_separator(String(stripped))
            separator_idx = i
            return (header_idx, separator_idx)
        end
    end

    return nothing
end

"""
    is_header(line::String) -> Bool

Check if a line is a markdown table header.
"""
function is_header(line::String)
    return startswith(line, "|") && occursin("|", line[2:end])
end

"""
    is_separator(line::String) -> Bool

Check if a line is a markdown table separator.
"""
function is_separator(line::String)
    return startswith(line, "|--") || (startswith(line, "|") && occursin("---", line))
end

"""
    parse_row(line::String, skip_headers::Bool=true) -> Union{Vector{String}, Nothing}

Parse a markdown table row into its column values.
"""
function parse_row(line::String, skip_headers::Bool = true)
    if isempty(line)
        return nothing
    end

    parts = split(line, "|")
    cleaned_parts = [strip(part) for part in parts if !isempty(strip(part))]

    if isempty(cleaned_parts)
        return nothing
    end

    # Skip header and separator rows if requested
    if skip_headers && is_header_or_sep(String(cleaned_parts[1]))
        return nothing
    end

    return cleaned_parts
end

"""
    is_header_or_sep(first_part::String) -> Bool

Check if a row is a header or separator row.
"""
function is_header_or_sep(first_part::String)
    # Check for separator pattern
    if occursin("---", first_part)
        return true
    end

    # Check for header patterns
    return any(occursin(pattern, first_part) for pattern in TABLE_HEADER_PATTERNS)
end
