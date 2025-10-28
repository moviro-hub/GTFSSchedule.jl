# Data structures for foreign ID references
struct ForeignReference
    table::String        # Referenced table (e.g., "stops")
    field::String        # Referenced field (e.g., "stop_id")
end

struct FieldForeign
    fieldname::String
    references::Vector{ForeignReference}  # Can have multiple refs (e.g., "X or Y")
    is_conditional::Bool  # Whether this field has conditional references
end

struct FileForeigns
    filename::String
    fields::Vector{FieldForeign}  # Only fields with Foreign ID references
end

"""
    parse_foreign_reference(ref_str::String) -> Union{ForeignReference, Nothing}

Parse a single reference like "stops.stop_id" or "`stops.stop_id`".
"""
function parse_foreign_reference(ref_str::String)
    # Clean up the reference string - remove backticks and whitespace
    cleaned = strip(replace(ref_str, "`" => ""))

    # Check if it contains a dot (table.field format)
    if occursin(".", cleaned)
        parts = split(cleaned, ".")
        if length(parts) >= 2
            table = strip_ext(String(strip(parts[1])))
            field = String(strip(parts[2]))
            if !isempty(table) && !isempty(field)
                return ForeignReference(table, field)
            end
        end
    end

    return nothing
end

"""
    extract_foreign_references(field_type_str::String) -> Tuple{Vector{ForeignReference}, Bool}

Extract all foreign references from field type string.
Checks if field_type contains "Foreign ID" and extracts references.
Returns (references, is_conditional) where is_conditional indicates if any references are conditional.
"""
function extract_foreign_references(field_type_str::String)
    references = ForeignReference[]
    is_conditional = false

    # Early return if no "Foreign ID" present
    !occursin("Foreign ID", field_type_str) && return (references, is_conditional)

    # Check if this is a conditional reference (contains "or ID")
    if occursin(r"or\s+ID", field_type_str)
        is_conditional = true
    end

    # Extract all backtick-wrapped references
    backtick_pattern = r"`([^`]+)`"
    for match in eachmatch(backtick_pattern, field_type_str)
        ref_str = String(match[1])
        ref = parse_foreign_reference(ref_str)
        ref !== nothing && push!(references, ref)
    end

    return (references, is_conditional)
end


"""
    extract_all_field_id_references(file_defs::Vector{FileFields}) -> Vector{FileForeigns}

Extract foreign ID reference information for all fields in all files.
Only includes fields that have Foreign ID references.
"""
function extract_all_field_id_references(file_defs::Vector{FileFields})
    result = FileForeigns[]

    for file_def in file_defs
        field_foreign_infos = FieldForeign[]

        for (_, field_def) in iterate_fields([file_def])
            # Extract foreign references from this field's type
            references, is_conditional = extract_foreign_references(field_def.field_type)

            # Only include fields that have foreign references
            if !isempty(references)
                field_info = FieldForeign(
                    field_def.fieldname,
                    references,
                    is_conditional
                )
                push!(field_foreign_infos, field_info)
            end
        end

        # Only include files that have fields with foreign references
        if !isempty(field_foreign_infos)
            file_info = FileForeigns(strip_ext(file_def.filename), field_foreign_infos)
            push!(result, file_info)
        end
    end

    return result
end
