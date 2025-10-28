"""
    generate_field_conditions(parsed_fields::Vector{FieldRules}) -> String

Generate source code for field validation rules:
- `const FIELD_RULES` with per-file field rules
"""
function generate_field_conditions(parsed_fields::Vector{FieldRules})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Generic field presence validator")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit FIELD_RULES dictionary
    push!(lines, "# Compact rule set distilled from parsed field-level conditions")
    push!(lines, "const FIELD_RULES = Dict(")
    for pf in parsed_fields
        fname = pf.filename
        push!(lines, "  :$fname => [")
        for fr in pf.fields
            # Each entry: field, presence, required, forbidden, conditions
            push!(lines, "        (")
            field_sym = occursin(".", fr.field) ? ":( $(fr.field) )" : ":$(fr.field)"
            push!(lines, "            field = $field_sym,")
            push!(lines, "            presence = \"$(fr.presence)\",")
            push!(lines, "            required = $(fr.required),")
            push!(lines, "            forbidden = $(fr.forbidden),")
            push!(lines, "            conditions = [")
            for c in fr.when_all_conditions
                field_sym = occursin(".", c.field) ? ":( $(c.field) )" : ":$(c.field)"
                push!(lines, "                (type = :field, file = :$(c.file), field = $field_sym, value = \"$(c.value)\"),")
            end
            push!(lines, "            ],")
            push!(lines, "        ),")
        end
        push!(lines, "  ],")
    end
    push!(lines, ")")
    push!(lines, "")

    return lines
end
