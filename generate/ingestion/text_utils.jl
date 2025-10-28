"""
    Text Utilities

Common text cleaning and formatting functions for parsing GTFS specification content.
"""

"""
    strip_markdown_bold(text::String) -> String

Remove markdown bold formatting from text.
"""
function strip_bold(text::AbstractString)
    text_str = String(text)
    if isempty(text_str)
        return text_str
    end
    return replace(text_str, r"\*\*([^*]+)\*\*" => s"\1")
end

"""
    strip_markdown_link(text::String) -> String

Extract text from markdown link format [text](link).
"""
function strip_link(text::AbstractString)
    text_str = String(text)
    if isempty(text_str)
        return text_str
    end

    match_result = match(r"\[([^\]]+)\]\([^)]+\)", text_str)
    return match_result !== nothing ? match_result[1] : text_str
end

"""
    normalize_html_breaks(text::String) -> String

Replace HTML break tags with newlines.
"""
function normalize_breaks(text::String)
    if isempty(text)
        return text
    end

    # Apply HTML break replacements
    text = replace(text, "<br><br>" => "\n\n")
    text = replace(text, "<br>" => "\n")
    return text
end

"""
    is_example_line(line::String) -> Bool

Check if line contains example content that should be filtered out.
"""
function is_example_line(line::String)
    if isempty(line)
        return false
    end

    example_indicators = ["Example:", "_Example"]
    return any(occursin(indicator, line) for indicator in example_indicators)
end
