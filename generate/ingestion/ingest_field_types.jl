"""
    parse_field_types(lines::Vector{String}) -> Dict{String, String}

Parse the dedicated Field Types section where entries look like:
"Color - A color encoded as a six-digit hexadecimal number. ...\nExample: ..."
Returns a Dict mapping the left-hand name to the full description (including examples and following lines until the next type entry or section end).
"""
function parse_field_types(lines::Vector{String})
    # Pattern for type entries: "TypeName - Description"
    return parse_section(lines, "Field Types", r"^([^-–:]+)\s*[-–:]\s*(.+)$", false)
end
