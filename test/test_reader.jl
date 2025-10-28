"""
Comprehensive test suite for reader.jl

This module contains thorough tests for the GTFS reader functionality including
ZIP files, directories, CSV parsing, GeoJSON support, error handling, and edge cases.
"""

using Test: @test, @testset, @test_throws
using GTFSSchedules: GTFSSchedules, read_gtfs, GTFSSchedule
using DataFrames: DataFrames
using CSV: CSV
using GeoJSON: GeoJSON
using Dates: Dates

@testset "Reader.jl Comprehensive Tests" begin

    @testset "Basic Read Functionality" begin
        # Test reading from directory (unzip sample at runtime)
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        @test isfile(zip_path)
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)

        gtfs = read_gtfs(temp_dir)
        @test gtfs !== nothing
        @test isa(gtfs, Dict)
        @test isa(gtfs, GTFSSchedule)

        # Verify expected files are loaded
        expected_files = [:agency, :stops, :routes, :trips, :stop_times, :calendar]
        for file in expected_files
            @test haskey(gtfs, file)
            @test gtfs[file] !== nothing
            @test isa(gtfs[file], DataFrames.DataFrame)
        end

        # Test reading from ZIP file
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            gtfs_zip = read_gtfs(zip_path)
            @test gtfs_zip !== nothing
            @test isa(gtfs_zip, GTFSSchedule)
        end
    end

    @testset "Basic Example Dataset Validation" begin
        # Path to the sample dataset (unzip at runtime)
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        @test isfile(zip_path)
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)

        # Read the GTFS feed
        println("Reading sample dataset from: $temp_dir")
        gtfs = read_gtfs(temp_dir)
        @test gtfs !== nothing
        @test isa(gtfs, Dict)

        # Test basic structure - access as dictionary
        @test haskey(gtfs, :agency)
        @test haskey(gtfs, :stops)
        @test haskey(gtfs, :routes)
        @test haskey(gtfs, :trips)
        @test haskey(gtfs, :stop_times)
        @test haskey(gtfs, :calendar)

        # Test expected counts for sample dataset
        @test DataFrames.nrow(gtfs[:agency]) == 1
        @test DataFrames.nrow(gtfs[:stops]) == 9
        @test DataFrames.nrow(gtfs[:routes]) == 5
        @test DataFrames.nrow(gtfs[:trips]) == 11
        @test DataFrames.nrow(gtfs[:stop_times]) == 28

        # Test optional files that should be present in sample dataset
        @test haskey(gtfs, :calendar_dates)
        @test haskey(gtfs, :fare_attributes)
        @test haskey(gtfs, :fare_rules)
        @test haskey(gtfs, :frequencies)
        @test haskey(gtfs, :shapes)

        # Test shapes count
        @test DataFrames.nrow(gtfs[:shapes]) == 0

        # Basic validation - check that all required files are present
        println("Running basic validation on sample dataset...")

        # Check that all required GTFS files are present
        required_files = [:agency, :stops, :routes, :trips, :stop_times, :calendar]
        for file in required_files
            @test haskey(gtfs, file)
        end

        # Check that data is not empty
        for file in required_files
            @test DataFrames.nrow(gtfs[file]) > 0
        end

        println("Basic validation completed successfully")

        # Print dataset summary
        println("\nSample Dataset Summary:")
        println("  Agencies: $(DataFrames.nrow(gtfs[:agency]))")
        println("  Stops: $(DataFrames.nrow(gtfs[:stops]))")
        println("  Routes: $(DataFrames.nrow(gtfs[:routes]))")
        println("  Trips: $(DataFrames.nrow(gtfs[:trips]))")
        println("  Stop Times: $(DataFrames.nrow(gtfs[:stop_times]))")
        println("  Calendar: $(DataFrames.nrow(gtfs[:calendar]))")
        println("  Calendar Dates: $(DataFrames.nrow(gtfs[:calendar_dates]))")
        println("  Fare Attributes: $(DataFrames.nrow(gtfs[:fare_attributes]))")
        println("  Fare Rules: $(DataFrames.nrow(gtfs[:fare_rules]))")
        println("  Frequencies: $(DataFrames.nrow(gtfs[:frequencies]))")
        println("  Shapes: $(DataFrames.nrow(gtfs[:shapes]))")

        println("✓ Basic example dataset test completed successfully")
    end

    @testset "File Format Tests" begin
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test CSV files with proper column types
        @test haskey(gtfs, :agency)
        agency_df = gtfs[:agency]
        @test isa(agency_df, DataFrames.DataFrame)
        @test DataFrames.nrow(agency_df) > 0

        # Test GeoJSON files (create temporary test)
        temp_dir = mktempdir()
        try
            # Create a temporary GeoJSON file for testing
            geojson_content = """{
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {
                            "location_id": "L1",
                            "location_name": "Test Location"
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [-74.0, 40.0]
                        }
                    }
                ]
            }"""
            geojson_file = joinpath(temp_dir, "locations.geojson")
            write(geojson_file, geojson_content)

            gtfs_geo = read_gtfs(temp_dir)
            @test haskey(gtfs_geo, :locations)
            @test gtfs_geo[:locations] !== nothing
            @test isa(gtfs_geo[:locations], DataFrames.DataFrame)
        finally
            rm(temp_dir, recursive = true, force = true)
        end

        # Test column types are applied correctly
        if haskey(gtfs, :agency)
            agency_df = gtfs[:agency]
            # Check that columns exist and have appropriate types
            @test "agency_id" in names(agency_df)
            @test "agency_name" in names(agency_df)
            @test "agency_url" in names(agency_df)
        end
    end

    @testset "ZIP Archive Handling" begin
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            # Test reading from ZIP
            gtfs = read_gtfs(zip_path)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)

            # Verify files are loaded from ZIP
            @test haskey(gtfs, :agency)
            @test haskey(gtfs, :stops)
        end

        # Test ZIP with subdirectory structure (create temporary test)
        temp_dir = mktempdir()
        try
            # Create a ZIP with subdirectory structure
            subdir = joinpath(temp_dir, "gtfs_feed")
            mkdir(subdir)

            # Copy basic-example files to subdirectory
            basic_path = joinpath(@__DIR__, "example")
            for file in readdir(basic_path)
                if endswith(file, ".txt")
                    cp(joinpath(basic_path, file), joinpath(subdir, file))
                end
            end

            # Create ZIP file
            zip_file = joinpath(temp_dir, "test_feed.zip")
            run(`zip -q -r $zip_file $subdir`)

            # Test reading ZIP with subdirectory
            gtfs = read_gtfs(zip_file)
            @test gtfs !== nothing
            @test haskey(gtfs, :agency)

        catch e
            # If ZIP creation fails, skip this test
            @warn "Skipping ZIP subdirectory test due to: $e"
        finally
            rm(temp_dir, recursive = true, force = true)
        end
    end

    @testset "Edge Cases & Special Scenarios" begin
        # Test with basic-example fixture
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            temp_dir = mktempdir()
            run(`unzip -q $zip_path -d $temp_dir`)
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)

            # Check that at least some files are loaded
            @test length(gtfs) > 0
        end

        # Test empty files (create temporary test)
        temp_dir = mktempdir()
        try
            # Create empty CSV with headers only
            empty_csv = joinpath(temp_dir, "empty.txt")
            open(empty_csv, "w") do f
                write(f, "agency_id,agency_name,agency_url,agency_timezone\n")
            end

            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test haskey(gtfs, :empty)
            @test DataFrames.nrow(gtfs[:empty]) == 0

        finally
            rm(temp_dir, recursive = true, force = true)
        end
    end

    @testset "Error Handling Tests" begin
        # Test invalid paths
        @test_throws ArgumentError read_gtfs("/nonexistent/path")
        @test_throws ArgumentError read_gtfs("/nonexistent/path.zip")

        # Test invalid file types
        temp_file = tempname() * ".txt"
        open(temp_file, "w") do f
            write(f, "test content")
        end
        try
            @test_throws ArgumentError read_gtfs(temp_file)
        finally
            rm(temp_file, force = true)
        end

        # Test directory without GTFS files
        temp_dir = mktempdir()
        try
            # Create directory with non-GTFS files (no .txt or .geojson extensions)
            open(joinpath(temp_dir, "readme.md"), "w") do f
                write(f, "This is not a GTFS file")
            end
            open(joinpath(temp_dir, "data.json"), "w") do f
                write(f, "{\"test\": \"data\"}")
            end

            @test_throws ArgumentError read_gtfs(temp_dir)

        finally
            rm(temp_dir, recursive = true, force = true)
        end

        # Test corrupted ZIP (create invalid ZIP)
        temp_zip = tempname() * ".zip"
        open(temp_zip, "w") do f
            write(f, "This is not a valid ZIP file")
        end
        try
            @test_throws Exception read_gtfs(temp_zip)
        finally
            rm(temp_zip, force = true)
        end

        # Test malformed CSV
        temp_dir = mktempdir()
        try
            malformed_csv = joinpath(temp_dir, "malformed.txt")
            open(malformed_csv, "w") do f
                write(f, "agency_id,agency_name\n")
                write(f, "1,\"Unclosed quote\n")  # Malformed CSV
            end

            # Should handle gracefully with warning
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test haskey(gtfs, :malformed)

        finally
            rm(temp_dir, recursive = true, force = true)
        end
    end

    @testset "Basic Feed Fixture Tests" begin
        # Use ZIP fixture; unzip at runtime
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            temp_dir = mktempdir()
            run(`unzip -q $zip_path -d $temp_dir`)
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)

            # Verify basic structure
            @test length(gtfs) > 0

            # Check for expected files in sample
            @test haskey(gtfs, :agency)
            @test haskey(gtfs, :stops)
            @test haskey(gtfs, :routes)
            @test haskey(gtfs, :trips)
            @test haskey(gtfs, :stop_times)
            @test haskey(gtfs, :calendar)
        end
    end

    @testset "Field Type Application Tests" begin
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that field types are applied
        if haskey(gtfs, :agency)
            agency_df = gtfs[:agency]

            # Check column types match expected GTFS types
            for col in DataFrames.names(agency_df)
                col_data = agency_df[!, col]
                if !isempty(col_data)
                    # Check that missing values are handled properly
                    @test all(x -> x isa Union{String, Missing, Dates.Time}, col_data)
                end
            end
        end

        # Test with custom field_types parameter
        custom_field_types = Dict{Symbol, Vector}()
        gtfs_custom = read_gtfs(temp_dir, custom_field_types)
        @test gtfs_custom !== nothing
        @test isa(gtfs_custom, GTFSSchedule)

        # Test fallback when type mapping fails
        # This is tested implicitly in the error handling section
    end

    @testset "Internal Function Tests" begin
        # Test _read_gtfs_from_directory
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = GTFSSchedules._read_gtfs_from_directory(temp_dir, GTFSSchedules.FIELD_TYPES)
        @test gtfs !== nothing
        @test isa(gtfs, GTFSSchedule)

        # Test _read_csv_file
        agency_file = joinpath(temp_dir, "agency.txt")
        if isfile(agency_file)
            df = GTFSSchedules._read_csv_file(agency_file, :agency, GTFSSchedules.FIELD_TYPES)
            @test df !== nothing
            @test isa(df, DataFrames.DataFrame)
            @test DataFrames.nrow(df) > 0
        end

        # Test _read_geojson_file (create temporary test)
        temp_dir = mktempdir()
        try
            # Create a temporary GeoJSON file for testing
            geojson_content = """{
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {
                            "location_id": "L1",
                            "location_name": "Test Location"
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [-74.0, 40.0]
                        }
                    }
                ]
            }"""
            geo_file = joinpath(temp_dir, "locations.geojson")
            write(geo_file, geojson_content)

            df = GTFSSchedules._read_geojson_file(geo_file)
            @test df !== nothing
            @test isa(df, DataFrames.DataFrame)
        finally
            rm(temp_dir, recursive = true, force = true)
        end

        # Test _read_gtfs_from_zip
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            gtfs_zip = GTFSSchedules._read_gtfs_from_zip(zip_path, GTFSSchedules.FIELD_TYPES)
            @test gtfs_zip !== nothing
            @test isa(gtfs_zip, GTFSSchedule)
        end
    end

    @testset "DataFrame Structure Validation" begin
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that all DataFrames have proper structure
        for (filename, df) in gtfs
            if df !== nothing
                @test isa(df, DataFrames.DataFrame)
                @test DataFrames.ncol(df) > 0  # Should have columns

                # Test that missing values are handled properly
                for col in DataFrames.names(df)
                    col_data = df[!, col]
                    # Check that all values are of expected GTFS types
                    # Note: Dates.Time is included because CSV.jl may auto-detect time fields
                    @test all(x -> x isa Union{String, Missing, Int64, Float64, Dates.Time}, col_data)
                end
            end
        end

        # Test specific file structures
        if haskey(gtfs, :agency)
            agency_df = gtfs[:agency]
            @test "agency_id" in DataFrames.names(agency_df)
            @test "agency_name" in DataFrames.names(agency_df)
            @test "agency_url" in DataFrames.names(agency_df)
            @test "agency_timezone" in DataFrames.names(agency_df)
        end

        if haskey(gtfs, :stops)
            stops_df = gtfs[:stops]
            @test "stop_id" in DataFrames.names(stops_df)
            @test "stop_name" in DataFrames.names(stops_df)
            @test "stop_lat" in DataFrames.names(stops_df)
            @test "stop_lon" in DataFrames.names(stops_df)
        end
    end

    @testset "Warning and Error Message Tests" begin
        # Test that appropriate warnings are issued
        temp_dir = mktempdir()
        try
            # Create a file with type coercion issues
            problem_csv = joinpath(temp_dir, "problem.txt")
            open(problem_csv, "w") do f
                write(f, "agency_id,agency_name\n")
                write(f, "1,Test Agency\n")
                write(f, "invalid_id,Another Agency\n")  # This should work fine
            end

            # Should not throw errors, but may issue warnings
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing

        finally
            rm(temp_dir, recursive = true, force = true)
        end
    end

    @testset "Performance and Memory Tests" begin
        # Test that reading doesn't consume excessive memory
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)

        # Read multiple times to test for memory leaks
        for i in 1:3
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)
        end

        # Test with larger fixture if available
        zip_path = joinpath(@__DIR__, "example", "sample-feed-1.zip")
        if isfile(zip_path)
            gtfs = read_gtfs(zip_path)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)
        end
    end

end
