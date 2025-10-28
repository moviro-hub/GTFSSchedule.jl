"""
    Section Utilities

Functions for parsing markdown sections and entries in GTFS specification content.
"""

"""
    is_header(line::String, section_name::String, level::Int) -> Bool

Check if line is a specific section header at the given level.
"""
function is_header(line::String, section_name::String, level::Int)
    if isempty(line) || level < 1
        return false
    end

    header_prefix = "#"^level
    expected_header = "$header_prefix $section_name"
    return occursin(expected_header, strip(line))
end

"""
    is_boundary(line::String, level::Int) -> Bool

Check if line starts a new section at the given level.
"""
function is_boundary(line::String, level::Int)
    if isempty(line) || level < 1
        return false
    end

    header_prefix = "#"^level
    return startswith(strip(line), header_prefix)
end

"""
    match_pattern(line::String, pattern::Regex) -> Union{RegexMatch, Nothing}

Match an entry pattern in a line, handling bullet markers and markdown formatting.
"""
function match_pattern(line::String, pattern::Regex)
    if isempty(line)
        return nothing
    end

    stripped = String(strip(line))
    # Normalize leading bullet markers
    stripped = replace(stripped, r"^[-*]\s+" => "")
    # Remove markdown bold formatting
    stripped = replace(stripped, r"\*\*([^*]+)\*\*" => s"\1")
    # Match entry pattern
    return match(pattern, stripped)
end

"""
    flush_desc(result::Dict{String, String}, key::String, desc_lines::Vector{String}, skip_examples::Bool)

Flush the current entry description to the result dictionary.
"""
function flush_desc(result::Dict{String, String}, key::String, desc_lines::Vector{String}, skip_examples::Bool)
    if isempty(key) || isempty(desc_lines)
        return
    end

    desc = join(desc_lines, "\n")
    desc = replace(desc, "<br><br>" => "\n\n")
    desc = replace(desc, "<br>" => "\n")

    if skip_examples
        desc = rstrip(desc)
    end

    return result[key] = desc
end

"""
    parse_section_with_entries(lines::Vector{String}, section_name::String, entry_pattern::Regex, skip_examples::Bool=false) -> Dict{String, String}

Parse a section with entry patterns (like Field Types or Field Signs).
"""
function parse_section(lines::Vector{String}, section_name::String, entry_pattern::Regex, skip_examples::Bool = false)
    if isempty(lines) || isempty(section_name)
        return Dict{String, String}()
    end

    result = Dict{String, String}()
    in_section = false
    current_key = ""
    current_desc_lines = String[]

    for line in lines
        # Check for section start
        if !in_section
            if is_header(line, section_name, 3)
                in_section = true
            end
            continue
        end

        # Check for section end
        if is_boundary(line, 3) && !occursin(section_name, strip(line))
            flush_desc(result, current_key, current_desc_lines, skip_examples)
            break
        end

        # Try to match a new entry
        match_result = match_pattern(line, entry_pattern)
        if match_result !== nothing
            # Skip example lines if requested
            if skip_examples && is_example_line(line)
                continue
            end

            flush_desc(result, current_key, current_desc_lines, skip_examples)
            empty!(current_desc_lines)

            current_key = String(strip(match_result.captures[1]))
            first_desc = String(strip(match_result.captures[2]))
            push!(current_desc_lines, first_desc)
            continue
        end

        # Treat as continuation of current description
        if !isempty(current_key)
            # Skip example lines even when they're continuation lines if requested
            if skip_examples && is_example_line(line)
                continue
            end
            push!(current_desc_lines, String(line))
        end
    end

    flush_desc(result, current_key, current_desc_lines, skip_examples)
    return result
end
