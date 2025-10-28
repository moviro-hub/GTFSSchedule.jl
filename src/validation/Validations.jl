module Validations

using DataFrames: DataFrames
using Dates: Dates

# Import FIELD_RULES, TABLE_RULES, ENUM_RULES, FIELD_CONSTRAINTS, and FIELD_ID_REFERENCES from the parent module
using ..GTFSSchedules: GTFSSchedule, FIELD_TYPES, FIELD_RULES, FILE_RULES, ENUM_RULES, FIELD_CONSTRAINTS, FIELD_ID_REFERENCES

include("types.jl")
include("utils.jl")
include("validators.jl")
include("validation.jl")
include("gtfs.jl")

# Export only the new validation functions
export validate_gtfs, print_validation_results, has_validation_errors

end
