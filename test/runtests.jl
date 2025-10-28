"""
Test suite for GTFSSchedule.jl package

This module contains comprehensive tests for the GTFS package functionality.
"""

using Test: Test, @testset
using GTFSSchedules: GTFSSchedules
using DataFrames: DataFrames

@testset "GTFSSchedule.jl Tests" begin
    include("test_reader.jl")
    include("validation/test_gtfs.jl")
    include("validation/test_validation.jl")
end
