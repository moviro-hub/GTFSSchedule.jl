"""
    RuleGenerations

Main module for GTFS specification parsing and rule generation.

This module orchestrates the complete pipeline from downloading the GTFS specification
to generating Julia validation rules. It includes four main sub-modules:

- `Download`: Downloads the official GTFS specification from GitHub
- `Ingestion`: Parses the markdown specification into structured data
- `Extraction`: Extracts validation rules and type information
- `Generation`: Generates Julia source files with validation rules

The module provides a complete data-driven approach to maintaining GTFS validation
rules that automatically adapt to specification changes.
"""
module RuleGenerations

include("download/Download.jl")
include("ingestion/Ingestion.jl")
include("extraction/Extraction.jl")
include("generation/Generation.jl")

end
