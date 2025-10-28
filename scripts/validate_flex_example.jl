#!/usr/bin/env julia

using GTFSSchedules
using Downloads


# Download to temp dir
url = "https://gtfs.org/assets/on-demand-services-between-multiple-zones-river-valley.zip"
temp_dir = mktempdir()
temp_file = joinpath(temp_dir, "on-demand-services-between-multiple-zones-river-valley.zip")
Downloads.download(url, temp_file)
# Read GTFS
gtfs = read_gtfs(temp_file)
# Validate GTFS
result = GTFSSchedules.Validations.validate_gtfs(gtfs)
println(result.summary)
# all validation messages ( of type info, warning, error)
# Redefine validity: true only if errors exist
is_valid = GTFSSchedules.Validations.has_validation_errors(result)
if is_valid
    GTFSSchedules.Validations.print_validation_results(result)
else
    println("✓ All validations passed!")
end
