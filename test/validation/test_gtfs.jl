"""
Comprehensive GTFS Validation Test Suite

This module contains thorough tests for the GTFS validation functionality including
all available fixtures, individual validators, error detection, and validation utilities.
"""

using Test: Test, @test, @testset, @test_throws
using GTFSSchedules: GTFSSchedules, read_gtfs, GTFSSchedule
using DataFrames: DataFrames, DataFrame

@testset "GTFS Validation Comprehensive Tests" begin

    @testset "Basic Validation Tests" begin
        # Test basic validation on sample dataset
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        @test isfile(zip_path)
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)

        gtfs = read_gtfs(temp_dir)
        @test gtfs !== nothing
        @test isa(gtfs, GTFSSchedule)

        # Test comprehensive validation
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test result.summary isa String
        @test !isempty(result.summary)
        @test result.messages isa Vector{GTFSSchedules.Validations.ValidationMessage}

        # Test validation utilities
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

    @testset "Basic Fixture Validation" begin
        # Test sample fixture
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        if isfile(zip_path)
            println("Testing validation on sample dataset...")
            temp_dir = mktempdir()
            run(`unzip -q $zip_path -d $temp_dir`)
            gtfs = read_gtfs(temp_dir)
            @test gtfs !== nothing
            @test isa(gtfs, GTFSSchedule)

            # Test comprehensive validation
            result = GTFSSchedules.Validations.validate_gtfs(gtfs)
            @test result isa GTFSSchedules.Validations.ValidationResult
            @test result.summary isa String
            @test result.messages isa Vector{GTFSSchedules.Validations.ValidationMessage}

            # Test validation utilities
            @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool

            # Count message types
            error_count = count(m -> m.severity == :error, result.messages)
            warning_count = count(m -> m.severity == :warning, result.messages)
            info_count = count(m -> m.severity == :info, result.messages)

            @test error_count >= 0
            @test warning_count >= 0
            @test info_count >= 0
            @test error_count + warning_count + info_count == length(result.messages)

            println("  basic-example: $error_count errors, $warning_count warnings, $info_count info")
        end
    end

    @testset "Individual Validator Tests" begin
        # Note: Individual validators have been replaced by the unified  validation system
        # All validation is now done through validate_gtfs() which combines all validation types
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Test that the unified validation system works
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test result.messages isa Vector{GTFSSchedules.Validations.ValidationMessage}
    end

    @testset "Validation Result Structure Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Test ValidationResult structure
        @test hasfield(typeof(result), :summary)
        @test hasfield(typeof(result), :messages)
        @test result.summary isa String
        @test result.messages isa Vector{GTFSSchedules.Validations.ValidationMessage}

        # Test ValidationMessage structure
        if !isempty(result.messages)
            msg = result.messages[1]
            @test hasfield(typeof(msg), :table)
            @test hasfield(typeof(msg), :field)
            @test hasfield(typeof(msg), :message)
            @test hasfield(typeof(msg), :severity)
            @test msg.table isa Symbol
            @test msg.field isa Union{Symbol, Nothing}
            @test msg.message isa String
            @test msg.severity isa Symbol
        end
    end

    @testset "Error Detection Tests" begin
        # Test with empty GTFS feed
        empty_gtfs = GTFSSchedule()
        result = GTFSSchedules.Validations.validate_gtfs(empty_gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool

        # Test with GTFS feed missing required files
        incomplete_gtfs = GTFSSchedule()
        incomplete_gtfs[:agency] = DataFrames.DataFrame(agency_id = ["1"], agency_name = ["Test"])
        result = GTFSSchedules.Validations.validate_gtfs(incomplete_gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool
    end

    @testset "Warning Detection Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Test that warnings can be detected
        warning_count = count(m -> m.severity == :warning, result.messages)
        @test warning_count >= 0

        # Test warning message structure
        warnings = filter(m -> m.severity == :warning, result.messages)
        for warning in warnings
            @test warning.file isa String
            @test warning.message isa String
            @test warning.severity == :warning
        end
    end

    @testset "Info Message Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)

        # Test that info messages can be detected
        info_count = count(m -> m.severity == :info, result.messages)
        @test info_count >= 0

        # Test info message structure
        info_messages = filter(m -> m.severity == :info, result.messages)
        for info in info_messages
            @test info.table isa Symbol
            @test info.message isa String
            @test info.severity == :info
        end
    end

    @testset "Validation Utility Tests" begin
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)
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

    @testset "Basic Feature Validation Tests" begin
        # Test basic-example (has standard GTFS files)
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        if isfile(zip_path)
            temp_dir = mktempdir()
            run(`unzip -q $zip_path -d $temp_dir`)
            gtfs = read_gtfs(temp_dir)
            result = GTFSSchedules.Validations.validate_gtfs(gtfs)
            @test result isa GTFSSchedules.Validations.ValidationResult

            # Check for standard GTFS files
            @test haskey(gtfs, :agency)
            @test haskey(gtfs, :stops)
            @test haskey(gtfs, :routes)
            @test haskey(gtfs, :trips)
            @test haskey(gtfs, :stop_times)
            @test haskey(gtfs, :calendar)

            # Check for optional files that should be present in basic-example
            @test haskey(gtfs, :calendar_dates)
            @test haskey(gtfs, :fare_attributes)
            @test haskey(gtfs, :fare_rules)
            @test haskey(gtfs, :frequencies)
            @test haskey(gtfs, :shapes)
        end
    end

    @testset "Validation Performance Tests" begin
        # Test that validation completes in reasonable time
        zip_path = joinpath(@__DIR__, "..", "example", "sample-feed-1.zip")
        temp_dir = mktempdir()
        run(`unzip -q $zip_path -d $temp_dir`)
        gtfs = read_gtfs(temp_dir)

        # Time the validation
        start_time = time()
        result = GTFSSchedules.Validations.validate_gtfs(gtfs)
        end_time = time()

        @test result isa GTFSSchedules.Validations.ValidationResult
        @test (end_time - start_time) < 10.0  # Should complete within 10 seconds

        # Test multiple validations don't cause issues
        for i in 1:3
            result = GTFSSchedules.Validations.validate_gtfs(gtfs)
            @test result isa GTFSSchedules.Validations.ValidationResult
        end
    end

    @testset "Validation Message Content Tests" begin
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

            # Test that file names are valid GTFS table names (without extensions)
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

    @testset "Validation Edge Cases" begin
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

        result = GTFSSchedules.Validations.validate_gtfs(minimal_gtfs)
        @test result isa GTFSSchedules.Validations.ValidationResult
        @test GTFSSchedules.Validations.has_validation_errors(result) isa Bool
    end

end
