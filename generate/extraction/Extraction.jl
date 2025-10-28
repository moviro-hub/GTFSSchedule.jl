"""
    Extraction

Module for extracting validation rules and type information from parsed GTFS data.

This module processes the structured data from the Ingestion module and extracts
specific validation rules and type information including:

- File-level and field-level conditions and requirements
- Enum values and validation rules
- Field type mappings and constraints
- Foreign key relationships and references
- Field constraints (Unique, Non-negative, etc.)

The module provides a comprehensive set of extractors that transform the parsed
specification into validation rules suitable for code generation.
"""
module Extraction

using ..Ingestion: DatasetFile, Field, FileFields, Presence

# Main extraction functions
export extract_all_file_conditions, extract_all_field_conditions, extract_all_field_enum_values
export extract_all_field_types, extract_all_field_id_references, extract_all_field_constraints

# Data structures - File/Field conditions
export FileRules, FileRule, FileCondition, FileFieldCondition
export FieldRules, FieldRule, FieldCondition

# Data structures - Types
export FieldType, FileTypes

# Data structures - Foreign references
export ForeignReference, FieldForeign, FileForeigns

# Data structures - Field constraints
export FieldConstraint, FileConstraints

# Data structures - Enums
export FileEnums, FieldEnum

# Utility modules
include("reference_utils.jl")
include("condition_utils.jl")

include("extract_file_conditions.jl")
include("extract_field_conditions.jl")
include("extract_field_enum_values.jl")
include("extract_field_types.jl")
include("extract_field_id_references.jl")
include("extract_field_constraints.jl")

end
