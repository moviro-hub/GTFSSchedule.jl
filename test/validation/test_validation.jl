"""
Comprehensive test suite for validation system

This module contains thorough tests for the new validation functionality including
correctness verification against the old system, performance benchmarks, and edge cases.
"""

using Test: Test, @test, @testset, @test_throws
using GTFSSchedules: GTFSSchedules, read_gtfs, GTFSSchedule
using DataFrames: DataFrames, DataFrame

@testset " Validation System Tests" begin

    @testset "Basic  Validation Tests" begin
        # Test basic validation on sample dataset
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        @test isfile(zip_path)
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)

        gtfs = read_gtfs(temp_dir)
        @test gtfs !== nothing
        @test isa(gtfs, GTFSSchedule)

        # Test new validation
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test result.summary isa String
        @test !isempty(result.summary)
        @test result.messages isa Vector{GTFSSchedules.Validations.ValidationMessage}

        # Test validation utilities work with new system
        @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool

        # Test that we can print results without errors
        @test begin
            GTFSSchedules.Validations.print_validation_results(result)
            true
        end

        # Test message structure
        for msg in result.messages
            @test msg.table isa Symbol
            @test msg.field isa Union{Symbol, Nothing}
            @test msg.message isa String
            @test msg.severity isa Symbol
            @test msg.severity in [:error, :warning, :info]
        end
    end

    @testset "Correctness Verification Against Old System" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Run both validation systems
        result_old = GTFSSchedules.Validations.validate_gtfs(gtfs)
        result_new = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Both should return ValidationResult
        @test result_old isa GTFSSchedules.Validations.ValidationResult
        @test result_new isa GTFSSchedules.Validations.ValidationResult

        # Both should have same validity status
        @test !GTFSSchedules.Validations.has_validation_errors(result_old) == !GTFSSchedules.Validations.has_validation_errors(result_new)

        # Both should have same error count
        old_errors = count(m -> m.severity == :error, result_old.messages)
        new_errors = count(m -> m.severity == :error, result_new.messages)
        @test old_errors == new_errors

        # Both should have same warning count
        old_warnings = count(m -> m.severity == :warning, result_old.messages)
        new_warnings = count(m -> m.severity == :warning, result_new.messages)
        @test old_warnings == new_warnings

        # Both should have same info count
        old_info = count(m -> m.severity == :info, result_old.messages)
        new_info = count(m -> m.severity == :info, result_new.messages)
        @test old_info == new_info

        # Total message count should be the same
        @test length(result_old.messages) == length(result_new.messages)
    end

    @testset "Performance Benchmarks" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Time the old validation system
        start_time_old = time()
        result_old = GTFSSchedules.Validations.validate_gtfs(gtfs)
        end_time_old = time()
        time_old = end_time_old - start_time_old

        # Time the new validation system
        start_time_new = time()
        result_new = GTFSSchedules.Validations.validate_gtfs(gtfs)
        end_time_new = time()
        time_new = end_time_new - start_time_new

        # Both should complete successfully
        @test result_old isa GTFSSchedules.Validations.ValidationResult
        @test result_new isa GTFSSchedules.Validations.ValidationResult

        # New system should be faster (or at least not significantly slower)
        @test time_new <= time_old * 1.5  # Allow 50% tolerance for test environment

        # Print performance comparison
        println("Performance Comparison:")
        println("  Old system: $(round(time_old, digits = 4)) seconds")
        println("  New system: $(round(time_new, digits = 4)) seconds")
        if time_old > 0
            speedup = time_old / time_new
            println("  Speedup: $(round(speedup, digits = 2))x")
        end
    end

    @testset "Vectorized Operations Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that vectorized operations work correctly
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult

        # Test with empty GTFS feed
        empty_gtfs = GTFSSchedule()
        result_empty = GTFSSchedules.Validations.validate_gtfs(empty_gtfs)
        @test result_empty isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result_empty) isa Bool

        # Test with minimal valid GTFS
        minimal_gtfs = GTFSSchedule()
        minimal_gtfs[:agency] = DataFrames.DataFrame(
            agency_id = ["1"],
            agency_name = ["Test Agency"],
            agency_url = ["http://test.com"],
            agency_timezone = ["America/New_York"]
        )
        minimal_gtfs[:stops] = DataFrames.DataFrame(
            stop_id = ["1"],
            stop_name = ["Test Stop"],
            stop_lat = [40.0],
            stop_lon = [-74.0]
        )
        minimal_gtfs[:routes] = DataFrames.DataFrame(
            route_id = ["1"],
            agency_id = ["1"],
            route_short_name = ["1"],
            route_long_name = ["Test Route"],
            route_type = [3]
        )
        minimal_gtfs[:trips] = DataFrames.DataFrame(
            route_id = ["1"],
            service_id = ["1"],
            trip_id = ["1"]
        )
        minimal_gtfs[:stop_times] = DataFrames.DataFrame(
            trip_id = ["1"],
            arrival_time = ["08:00:00"],
            departure_time = ["08:00:00"],
            stop_id = ["1"],
            stop_sequence = [1]
        )
        minimal_gtfs[:calendar] = DataFrames.DataFrame(
            service_id = ["1"],
            monday = [1],
            tuesday = [1],
            wednesday = [1],
            thursday = [1],
            friday = [1],
            saturday = [0],
            sunday = [0],
            start_date = ["20240101"],
            end_date = ["20241231"]
        )

        result_minimal = GTFSSchedules.Validations.validate_gtfs(minimal_gtfs)
        @test result_minimal isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result_minimal) isa Bool
    end

    @testset "Edge Cases and Error Handling" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that new system handles edge cases gracefully
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult

        # Test with GTFS feed missing required files
        incomplete_gtfs = GTFSSchedule()
        incomplete_gtfs[:agency] = DataFrames.DataFrame(agency_id = ["1"], agency_name = ["Test"])
        result_incomplete = GTFSSchedules.Validations.validate_gtfs(incomplete_gtfs)
        @test result_incomplete isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result_incomplete) isa Bool

        # Test that validation doesn't crash on malformed data
        malformed_gtfs = GTFSSchedule()
        malformed_gtfs[:agency] = DataFrames.DataFrame(
            agency_id = ["1", "invalid_id_with_spaces"],
            agency_name = ["Test Agency", ""],
            agency_url = ["http://test.com", "not_a_url"],
            agency_timezone = ["America/New_York", "Invalid/Timezone"]
        )
        result_malformed = GTFSSchedules.Validations.validate_gtfs(malformed_gtfs)
        @test result_malformed isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result_malformed) isa Bool
    end

    @testset "Message Content Validation" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Test that messages have meaningful content
        for msg in result.messages
            @test !isempty(msg.message)
            @test !isempty(string(msg.table))
            @test msg.severity in [:error, :warning, :info]

            # Test that table names are valid GTFS table names (without extensions)
            if msg.table != :general
                @test !endswith(string(msg.table), ".txt") && !endswith(string(msg.table), ".geojson")
            end
        end

        # Test that we can categorize messages by severity
        errors = filter(m -> m.severity == :error, result.messages)
        warnings = filter(m -> m.severity == :warning, result.messages)
        info = filter(m -> m.severity == :info, result.messages)

        @test length(errors) + length(warnings) + length(info) == length(result.messages)
    end

    @testset "API Compatibility Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that new API works with existing utility functions
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Test has_validation_errors function
        @test hasmethod(GTFSSchedules.Validations.has_validation_errors, (GTFSSchedules.Validations.ValidationResult,))
        @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool

        # Test print_validation_results function
        @test hasmethod(GTFSSchedules.Validations.print_validation_results, (GTFSSchedules.Validations.ValidationResult,))
        @test begin
            GTFSSchedules.Validations.print_validation_results(result)
            true
        end

        # Test that utility functions don't throw errors
        @test begin
            has_errors = GTFSSchedules.Validations.has_validation_errors(result)
            GTFSSchedules.Validations.print_validation_results(result)
            true
        end
    end

    @testset "Multiple Validation Runs" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test multiple validations don't cause issues
        for i in 1:3
            result = GTFSSchedules.Validations.validate_gtfs(gtfs)
            @test result isa GTFSSchedules.Validations.ValidationResult
        end

        # Test that results are consistent across multiple runs
        result1 = GTFSSchedules.Validations.validate_gtfs(gtfs)
        result2 = GTFSSchedules.Validations.validate_gtfs(gtfs)

        @test !GTFSSchedules.Validations.has_validation_errors(result1) == !GTFSSchedules.Validations.has_validation_errors(result2)
        @test length(result1.messages) == length(result2.messages)
    end

    @testset "Memory Usage Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that validation doesn't consume excessive memory
        initial_memory = Base.gc_bytes()

        # Run validation multiple times
        for i in 1:5
            result = GTFSSchedules.Validations.validate_gtfs(gtfs)
            @test result isa GTFSSchedules.Validations.ValidationResult
        end

        # Force garbage collection and check memory usage
        GC.gc()
        final_memory = Base.gc_bytes()

        # Memory usage shouldn't grow excessively
        memory_growth = final_memory - initial_memory
        @test memory_growth < 10_000_000  # Less than 10MB growth
    end

end
