"""
    ValidationMessage

Represents a specific validation message with context.

# Fields
- `table::Symbol`: Name of the GTFS table where the message occurred
- `field::Union{Symbol, Nothing}`: Name of the field (if applicable)
- `message::String`: Message text
- `severity::Symbol`: Message severity (:error, :warning, or :info)
"""
struct ValidationMessage
    table::Symbol
    field::Union{Symbol, Nothing}
    message::String
    severity::Symbol  # :error, :warning, or :info
end

"""
    ValidationResult

Result of GTFS validation containing errors and warnings.

# Fields
- `messages::Vector{ValidationMessage}`: List of validation messages
- `summary::String`: Summary of validation results
"""
struct ValidationResult
    messages::Vector{ValidationMessage}
    summary::String
end
