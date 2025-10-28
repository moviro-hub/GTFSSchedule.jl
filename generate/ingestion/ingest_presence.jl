"""
    Presence

Represents presence/requirement information for GTFS fields.
"""
struct Presence
    presence::String
    description::String
end

"""
    parse_presence(lines::Vector{String}) -> Vector{Presence}

Extract presence types and their descriptions from the GTFS specification.
Looks for the presence definitions in the "Document Conventions" section.
"""
function parse_presence_types(lines::Vector{String})
    presence_types = Presence[]

    for line in lines
        stripped = strip(line)

        # Look for presence definitions in the format: "* **Required** - Description"
        if startswith(stripped, "* **") && occursin(" - ", stripped)
            presence_type, description = extract_presence_info(String(stripped))
            if !isempty(presence_type) && !isempty(description)
                push!(presence_types, Presence(presence_type, description))
            end
        end
    end

    return presence_types
end

function extract_presence_info(stripped::String)
    # Remove bullet point and extract content
    content = replace(stripped, r"^\*\s*" => "")

    # Split on " - " to separate presence type from description
    parts = split(content, " - ", limit = 2)
    if length(parts) != 2
        return "", ""
    end

    presence_type = strip(replace(parts[1], r"\*\*" => ""))
    description = strip(parts[2])

    # Clean up description
    description = replace(description, r"\.$" => "")
    description = strip(description)

    # Only add if it looks like a presence type
    if presence_type in ["Required", "Optional", "Conditionally Required", "Conditionally Forbidden", "Recommended"]
        return presence_type, description
    end

    return "", ""
end

"""
    normalize_presence_type(presence_text::String, presence_types::Vector{Presence}) -> String

Clean and normalize presence/requirement text to a standard form.
"""
function normalize_presence_type(presence_text::AbstractString, presence_types::Vector{Presence})
    # Clean markdown formatting and whitespace
    clean_text = strip_bold(String(presence_text))
    clean_text = strip(clean_text)

    # Sort presence types by length (longest first) to prioritize more specific matches
    sorted_presence_types = sort(presence_types, by = x -> length(x.presence), rev = true)

    # Find matching presence type (check longest first)
    for presence_info in sorted_presence_types
        if occursin(presence_info.presence, clean_text)
            return presence_info.presence
        end
    end

    return "Unknown"
end

"""
    get_presence_description(presence_type::String, presence_types::Vector{Presence}) -> String

Get the description for a normalized presence type.
"""
function get_presence_desc(presence_type::String, presence_types::Vector{Presence})
    for presence_info in presence_types
        if presence_info.presence == presence_type
            return presence_info.description
        end
    end
    return "Unknown presence requirement"
end

"""
    is_valid_presence(presence_type::String, presence_types::Vector{Presence}) -> Bool

Check if a presence type is valid.
"""
function is_valid_presence_type(presence_type::String, presence_types::Vector{Presence})
    return any(presence_info.presence == presence_type for presence_info in presence_types)
end
