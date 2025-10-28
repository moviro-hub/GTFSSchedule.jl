"""
    Condition Utilities

Functions for extracting and parsing conditions from GTFS specification text.
"""

"""
    extract_condition_section(text::String, markers::Vector{String}) -> String

Extract a condition section from text using the provided markers.
"""
function extract_condition_section(text::String, markers::Vector{String})
    if isempty(text) || isempty(markers)
        return ""
    end

    for marker in markers
        marker_position = findfirst(marker, text)
        if marker_position !== nothing
            section_start = last(marker_position)
            section_text = text[section_start:end]

            # Normalize HTML breaks to newlines
            section_text = replace(section_text, "<br><br>" => "\n")
            section_text = replace(section_text, "<br>" => "\n")

            return section_text
        end
    end

    return ""
end

"""
    parse_presence_flags(presence::String) -> Tuple{Bool, Bool}

Parse presence type into required/forbidden flags.
"""
function parse_presence_flags(presence::String)
    if presence == "Conditionally Required"
        return true, false
    elseif presence == "Conditionally Forbidden"
        return false, true
    else
        return false, false
    end
end

"""
    parse_line_requirement_level(line::String, field_presence::String) -> Tuple{Bool, Bool}

Parse the requirement level (Required/Optional/Forbidden) from a condition line.
"""
function parse_line_requirement_level(line::String, field_presence::String)
    line_lower = lowercase(line)

    # Check for explicit requirement markers in the line
    if occursin(r"\*\*required\*\*|^-\s*required\s+for", line_lower)
        return true, false
    elseif occursin(r"\*\*forbidden\*\*|^-\s*forbidden\s+for", line_lower)
        return false, true
    elseif occursin(r"optional\s+for", line_lower)
        return false, false  # Will be skipped
    end

    # Fallback to field presence if no explicit marker
    return parse_presence_flags(field_presence)
end

"""
    parse_condition_lines(section::String) -> Vector{String}

Parse condition section into individual condition lines.
"""
function parse_condition_lines(section::String)
    if isempty(section)
        return String[]
    end

    lines = filter(!isempty, strip.(split(section, r"<br>|\n")))
    condition_lines = String[]

    for line in lines
        line_str = String(line)
        if startswith(line_str, "-")
            push!(condition_lines, line_str)
        end
    end

    return condition_lines
end
