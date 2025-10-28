# Examples

**Essential examples for reading and validating GTFS data.**

## Reading GTFS Data

```julia
using GTFSSchedules
using DataFrames

# Read from ZIP file (matches README)
gtfs = read_gtfs("./test/example/sample-feed-1.zip")

# Read from directory
gtfs = read_gtfs("/path/to/unzipped/gtfs/")
```

## Basic Data Access

```julia
# Access tables as DataFrames
println("Agencies: ", nrow(gtfs[:agency]))
println("Stops: ", nrow(gtfs[:stops]))
println("Routes: ", nrow(gtfs[:routes]))

# Filter data
bus_routes = filter(row -> row.route_type == 3, gtfs[:routes])
println("Bus routes: ", nrow(bus_routes))
```

## Validation

```julia
# Validate the feed
result = GTFSSchedules.Validations.validate_gtfs(gtfs)

# Check results
if !GTFSSchedules.Validations.has_validation_errors(result)
    println("✓ Feed is valid!")
else
    println("✗ Issues found: ", result.summary)
    GTFSSchedules.Validations.print_validation_results(result)
end
```
