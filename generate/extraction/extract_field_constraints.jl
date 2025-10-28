# Data structures for field constraints
struct FieldConstraint
    fieldname::String
    constraint::String  # e.g., "Non-negative", "Unique", "Positive"
end

struct FileConstraints
    filename::String
    fields::Vector{FieldConstraint}  # Only fields with constraints
end

"""
    extract_available_constraints(field_signs::Dict{String,String}) -> Vector{String}

Extract constraint names from field_signs keys plus "Unique".
These are the constraint types that can appear in field type strings.
"""
function extract_available_constraints(field_signs::Dict{String, String})
    constraints = collect(keys(field_signs))
    push!(constraints, "Unique")  # Always include "Unique" as a special case
    return constraints
end

"""
    extract_field_constraint(field_type_str::String, available_constraints::Vector{String}) -> Union{String, Nothing}

Extract constraint from field type string.
Search for each constraint from available_constraints in field_type_str.
Returns first found constraint or nothing.
"""
function extract_field_constraint(field_type_str::String, available_constraints::Vector{String})
    field_lower = lowercase(field_type_str)

    # Search for each constraint (case-insensitive)
    for constraint in available_constraints
        occursin(lowercase(constraint), field_lower) && return constraint
    end

    return nothing
end

"""
    extract_all_field_constraints(file_defs::Vector{FileFields}, field_signs::Dict{String,String}) -> Vector{FileConstraints}

Extract constraint information for all fields in all files.
Only includes fields that have constraints.
"""
function extract_all_field_constraints(file_defs::Vector{FileFields}, field_signs::Dict{String, String})
    result = FileConstraints[]

    # Get all available constraints from field_signs + "Unique"
    available_constraints = extract_available_constraints(field_signs)

    for file_def in file_defs
        field_constraint_infos = FieldConstraint[]

        for (_, field_def) in iterate_fields([file_def])
            # Extract constraint from this field's type
            constraint = extract_field_constraint(field_def.field_type, available_constraints)

            # Only include fields that have constraints
            if constraint !== nothing
                field_info = FieldConstraint(
                    field_def.fieldname,
                    constraint
                )
                push!(field_constraint_infos, field_info)
            end
        end

        # Only include files that have fields with constraints
        if !isempty(field_constraint_infos)
            file_info = FileConstraints(strip_ext(file_def.filename), field_constraint_infos)
            push!(result, file_info)
        end
    end

    return result
end
