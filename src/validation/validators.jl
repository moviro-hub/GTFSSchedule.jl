# =============================================================================
# TYPE VALIDATION FUNCTIONS
# =============================================================================

validate_color(value::String) = match(r"^[0-9A-Fa-f]{6}$", value) !== nothing
validate_color(value::Missing) = true
validate_color(value::Any) = false

validate_currency_code(value::String) = match(r"^[A-Za-z]{3}$", value) !== nothing
validate_currency_code(value::Missing) = true
validate_currency_code(value::Any) = false

validate_currency_amount(value::String) = match(r"^[\d\.\-]+$", value) !== nothing
validate_currency_amount(value::Missing) = true
validate_currency_amount(value::Any) = false

function validate_date(value::String)
    if match(r"^\d{8}$", value) === nothing
        return false
    end

    year = parse(Int, value[1:4])
    month = parse(Int, value[5:6])
    day = parse(Int, value[7:8])

    try
        Dates.Date(year, month, day)
        return true
    catch
        return false
    end
end
validate_date(value::Missing) = true
validate_date(value::Any) = false

validate_email(value::String) = match(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", value) !== nothing
validate_email(value::Missing) = true
validate_email(value::Any) = false

validate_enum(value::Int64) = true
validate_enum(value::Missing) = true
validate_enum(value::Any) = false

validate_id(value::String) = !isempty(value)
validate_id(value::Missing) = true
validate_id(value::Any) = false

validate_language_code(value::String) = match(r"^[a-z]{2}(-[A-Z]{2})?$", value) !== nothing
validate_language_code(value::Missing) = true
validate_language_code(value::Any) = false

validate_latitude(value::Float64) = value >= -90.0 && value <= 90.0
validate_latitude(value::Missing) = true
validate_latitude(value::Any) = false

validate_longitude(value::Float64) = value >= -180.0 && value <= 180.0
validate_longitude(value::Missing) = true
validate_longitude(value::Any) = false

validate_float(value::Float64) = true
validate_float(value::Missing) = true
validate_float(value::Any) = false

validate_integer(value::Int64) = true
validate_integer(value::Missing) = true
validate_integer(value::Any) = false

function validate_phone_number(value::String)
    return match(r"^[\+]?[\(\)\s\-\d\w]+$", value) !== nothing && !isempty(strip(value))
end
validate_phone_number(value::Missing) = true
validate_phone_number(value::Any) = false

function validate_time(value::String)
    # GTFS Time: HH:MM:SS where H:MM:SS is also accepted; hours may exceed 24
    m = match(r"^(\d{1,2}):(\d{2}):(\d{2})$", value)
    if m === nothing
        return false
    end

    hours = parse(Int, m.captures[1])
    minutes = parse(Int, m.captures[2])
    seconds = parse(Int, m.captures[3])

    return hours >= 0 &&
        minutes >= 0 && minutes <= 59 &&
        seconds >= 0 && seconds <= 59
end
validate_time(value::Missing) = true
validate_time(value::Any) = false

validate_text(value::String) = true
validate_text(value::Missing) = true
validate_text(value::Any) = false

function _matches_iana_pattern(value::String)
    valid_patterns = [
        r"^Africa/[A-Za-z_]+$",
        r"^America/[A-Za-z_]+$",
        r"^Antarctica/[A-Za-z_]+$",
        r"^Asia/[A-Za-z_]+$",
        r"^Atlantic/[A-Za-z_]+$",
        r"^Australia/[A-Za-z_]+$",
        r"^Europe/[A-Za-z_]+$",
        r"^Indian/[A-Za-z_]+$",
        r"^Pacific/[A-Za-z_]+$",
    ]

    for pattern in valid_patterns
        if match(pattern, value) !== nothing
            return true
        end
    end
    return false
end

function validate_timezone(value::String)
    if isempty(value)
        return false
    end

    if (
            match(r"^GMT[+-]\d+$", value) !== nothing ||
                match(r"^EST$|^EDT$|^CST$|^CDT$|^MST$|^MDT$|^PST$|^PDT$", value) !== nothing
        )
        return false
    end

    if _matches_iana_pattern(value)
        return true
    end

    return value == "UTC"
end
validate_timezone(value::Missing) = true
validate_timezone(value::Any) = false

validate_url(value::String) = match(r"^https?://[^\s]+$", value) !== nothing
validate_url(value::Missing) = true
validate_url(value::Any) = false

# -----------------------------------------------------------------------------
# Local time validator (wall clock time): H:MM:SS with 0 <= hours <= 24
# If hours == 24, only 24:00:00 is allowed per common GTFS semantics.
function validate_local_time(value::String)
    m = match(r"^(\d{1,2}):(\d{2}):(\d{2})$", value)
    if m === nothing
        return false
    end

    hours = parse(Int, m.captures[1])
    minutes = parse(Int, m.captures[2])
    seconds = parse(Int, m.captures[3])

    if hours < 0 || hours > 24
        return false
    end
    if minutes < 0 || minutes > 59
        return false
    end
    if seconds < 0 || seconds > 59
        return false
    end
    if hours == 24 && (minutes != 0 || seconds != 0)
        return false
    end
    return true
end
validate_local_time(value::Missing) = true
validate_local_time(value::Any) = false

# =============================================================================
# CONSTRAINT VALIDATION FUNCTIONS
# =============================================================================

validate_non_negative(value::Real) = value >= zero(value)
validate_non_negative(value::Missing) = true
validate_non_negative(value::Any) = false

validate_positive(value::Real) = value > zero(value)
validate_positive(value::Missing) = true
validate_positive(value::Any) = false

validate_non_zero(value::Real) = value != zero(value)
validate_non_zero(value::Missing) = true
validate_non_zero(value::Any) = false

validate_unique(values::Vector{T}) where {T} = allunique(skipmissing(values))
validate_unique(values) = validate_unique(collect(values))

# =============================================================================
# VALIDATOR MAPPINGS
# =============================================================================

const GTFS_TYPE_VALIDATORS = Dict(
    :ID => validate_id,
    :Enum => validate_enum,
    :Timezone => validate_timezone,
    :Date => validate_date,
    :Time => validate_time,
    :LocalTime => validate_local_time,
    :Latitude => validate_latitude,
    :Longitude => validate_longitude,
    :Float => validate_float,
    :Integer => validate_integer,
    :Text => validate_text,
    :Email => validate_email,
    :PhoneNumber => validate_phone_number,
    :URL => validate_url,
    :LanguageCode => validate_language_code,
    :CurrencyCode => validate_currency_code,
    :CurrencyAmount => validate_currency_amount,
    :Color => validate_color,
)

const GTFS_CONSTRAINTS_VALIDATORS = Dict(
    "Unique" => validate_unique,
    "Non-negative" => validate_non_negative,
    "Positive" => validate_positive,
    "Non-zero" => validate_non_zero,
)


# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

"""
    validate_column_types(column, gtfs_type) -> BitVector

Validate an entire column against its GTFS type using vectorized operations.
Returns a BitVector where true indicates valid values.

# Arguments
- `column`: DataFrame column to validate
- `gtfs_type`: GTFS type symbol (:ID, :Text, :URL, etc.)

# Returns
- `BitVector`: Boolean array indicating validity of each element
"""
function validate_column_types(column, gtfs_type)
    validator = get(GTFS_TYPE_VALIDATORS, gtfs_type, nothing)
    validator === nothing && return trues(length(column))

    # Vectorized validation - much faster than row-by-row
    return map(validator, column)
end

"""
    validate_column_constraints_vectorized(column, constraints, field_name) -> BitVector

Validate an entire column against its constraints using vectorized operations.
Returns a BitVector where true indicates valid values.

# Arguments
- `column`: DataFrame column to validate
- `constraints`: Vector of constraint rules for the field
- `field_name`: Name of the field being validated

# Returns
- `BitVector`: Boolean array indicating validity of each element
"""
function validate_column_constraints(column, constraints, field_name)
    valid = trues(length(column))

    for constraint in constraints
        if constraint.field == field_name
            validator = get(GTFS_CONSTRAINTS_VALIDATORS, constraint.constraint, nothing)
            validator === nothing && continue

            if constraint.constraint == "Unique"
                # Column-level constraint - check uniqueness across entire column
                valid = valid .& validator(column)
            else
                # Element-level constraint - validate each element
                valid = valid .& map(validator, column)
            end
        end
    end

    return valid
end

"""
    validate_column_enums_vectorized(column, enum_rules, field_name) -> BitVector

Validate an entire column against enum rules using vectorized operations.
Returns a BitVector where true indicates valid values.

# Arguments
- `column`: DataFrame column to validate
- `enum_rules`: Vector of enum rules for the field
- `field_name`: Name of the field being validated

# Returns
- `BitVector`: Boolean array indicating validity of each element
"""
function validate_column_enums(column, enum_rules, field_name)
    valid = trues(length(column))

    for rule in enum_rules
        if rule.field == field_name
            allowed_values = _extract_allowed_values(rule.enum_values)
            allow_empty = get(rule, :allow_empty, false)

            # Vectorized enum validation
            enum_valid = map(column) do value
                _validate_enum_value_vectorized(value, allowed_values, allow_empty)
            end

            valid = valid .& enum_valid
        end
    end

    return valid
end

"""
    validate_column_references_vectorized(column, id_refs, field_name, gtfs_feed) -> BitVector

Validate an entire column against ID reference rules using vectorized operations.
Returns a BitVector where true indicates valid values.

# Arguments
- `column`: DataFrame column to validate
- `id_refs`: Vector of ID reference rules for the field
- `field_name`: Name of the field being validated
- `gtfs_feed`: Complete GTFS feed for reference validation

# Returns
- `BitVector`: Boolean array indicating validity of each element
"""
function validate_column_references(column, id_refs, field_name, gtfs_feed)
    valid = trues(length(column))

    for ref_rule in id_refs
        if ref_rule.field == field_name
            if ref_rule.is_conditional
                continue  # Skip conditional references for now
            end

            valid_values = _collect_valid_reference_values(gtfs_feed, ref_rule.references)
            isempty(valid_values) && continue

            # Vectorized reference validation
            ref_valid = map(column) do value
                _validate_reference_value_vectorized(value, valid_values)
            end

            valid = valid .& ref_valid
        end
    end

    return valid
end

"""
    add_validation_messages!(messages, table_name, field_name,
                           type_valid, constraint_valid, enum_valid, ref_valid)

Add validation messages for invalid values based on vectorized validation results.

# Arguments
- `messages`: Vector to append messages to
- `table_name`: Name of the GTFS table
- `field_name`: Name of the field being validated
- `type_valid`: BitVector indicating type validation results
- `constraint_valid`: BitVector indicating constraint validation results
- `enum_valid`: BitVector indicating enum validation results
- `ref_valid`: BitVector indicating reference validation results
"""
function add_validation_messages!(
        messages, table_name, field_name,
        type_valid, constraint_valid, enum_valid, ref_valid
    )
    # Combine all validation results
    overall_valid = type_valid .& constraint_valid .& enum_valid .& ref_valid

    # Find invalid rows
    invalid_rows = findall(.!overall_valid)

    # Add messages for invalid rows
    for row_idx in invalid_rows
        if !type_valid[row_idx]
            push!(
                messages, ValidationMessage(
                    table_name, field_name,
                    "Row $row_idx: Invalid type", :error
                )
            )
        end
        if !constraint_valid[row_idx]
            push!(
                messages, ValidationMessage(
                    table_name, field_name,
                    "Row $row_idx: Constraint violation", :error
                )
            )
        end
        if !enum_valid[row_idx]
            push!(
                messages, ValidationMessage(
                    table_name, field_name,
                    "Row $row_idx: Invalid enum value", :error
                )
            )
        end
        if !ref_valid[row_idx]
            push!(
                messages, ValidationMessage(
                    table_name, field_name,
                    "Row $row_idx: Invalid reference", :error
                )
            )
        end
    end
    return
end

# =============================================================================
# HELPER FUNCTIONS FOR VECTORIZED VALIDATION
# =============================================================================

"""
    _validate_enum_value_vectorized(value, allowed_values, allow_empty) -> Bool

Vectorized enum value validation helper.
"""
function _validate_enum_value_vectorized(value, allowed_values, allow_empty::Bool)
    # Check if value is missing or empty
    if ismissing(value) || (isa(value, AbstractString) && isempty(value))
        return allow_empty
    end

    # Validate non-empty values
    return value in allowed_values
end

"""
    _validate_reference_value_vectorized(value, valid_values) -> Bool

Vectorized reference value validation helper.
"""
function _validate_reference_value_vectorized(value, valid_values)
    ismissing(value) && return true

    # Allow empty values for optional foreign ID references
    if string(value) == "" || string(value) == "0"
        return true
    end

    return value in valid_values
end

"""
    prepare_validation_arrays(column_length) -> Tuple{BitVector, BitVector, BitVector, BitVector}

Pre-allocate validation result arrays for better performance.
"""
function prepare_validation_arrays(column_length)
    return (trues(column_length), trues(column_length), trues(column_length), trues(column_length))
end
