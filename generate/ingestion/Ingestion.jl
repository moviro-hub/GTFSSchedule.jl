"""
    Ingestion

Module for parsing the GTFS specification markdown into structured data.

This module handles the parsing of the downloaded GTFS specification markdown
file and extracts structured information including:

- Dataset file definitions and relationships
- Field definitions with types and constraints
- Field type mappings and validation rules
- Field presence requirements and signs

The module provides a clean interface for converting the raw markdown
specification into Julia data structures suitable for further processing.
"""
module Ingestion

# Data structures
export DatasetFile, Field, FileFields, Presence

# Main parsing functions
export parse_dataset_files, parse_field_definitions, parse_field_types, parse_field_signs, parse_presence_types

# Utility modules
include("text_utils.jl")
include("table_utils.jl")
include("section_utils.jl")

include("ingest_presence.jl")
include("ingest_dataset_files.jl")
include("ingest_field_definitions.jl")
include("ingest_field_types.jl")
include("ingest_field_signs.jl")

end
