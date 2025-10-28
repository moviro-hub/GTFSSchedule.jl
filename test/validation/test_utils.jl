# =============================================================================
# TEST UTILITIES MODULE
# =============================================================================

module TestUtils

using GTFSSchedules
using DataFrames

"""
    create_basic_gtfs() -> GTFSSchedule

Create a basic GTFS dataset with all required files.
"""
function create_basic_gtfs()
    gtfs = GTFSSchedule()

    # Required files
    gtfs[:agency] = DataFrame(
        agency_id = ["DTA"],
        agency_name = ["Demo Transit Authority"],
        agency_url = ["http://example.com"],
        agency_timezone = ["America/New_York"]
    )

    gtfs[:routes] = DataFrame(
        route_id = ["R1"],
        route_short_name = ["1"],
        route_long_name = ["Route 1"],
        route_type = [3]
    )

    gtfs[:trips] = DataFrame(
        trip_id = ["T1"],
        route_id = ["R1"],
        service_id = ["SERVICE1"]
    )

    gtfs[:stops] = DataFrame(
        stop_id = ["S1"],
        stop_name = ["Stop 1"],
        stop_lat = [40.0],
        stop_lon = [-74.0]
    )

    gtfs[:calendar] = DataFrame(
        service_id = ["SERVICE1"],
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

    gtfs[:stop_times] = DataFrame(
        trip_id = ["T1"],
        stop_id = ["S1"],
        stop_sequence = [1],
        arrival_time = ["06:00:00"],
        departure_time = ["06:00:00"]
    )

    return gtfs
end

"""
    create_gtfs_with_field_values(gtfs::GTFSSchedule, filename::String, field::Symbol, values::Vector) -> GTFSSchedule

Create a copy of GTFS with specific field values for testing.
"""
function create_gtfs_with_field_values(gtfs::GTFSSchedule, filename::String, field::Symbol, values::Vector)
    new_gtfs = deepcopy(gtfs)
    table = replace(filename, r"\.(txt|geojson)$" => "")
    table_sym = Symbol(table)

    if haskey(new_gtfs, table_sym)
        df = new_gtfs[table_sym]
        df[!, field] = values
        new_gtfs[table_sym] = df
    else
        # Create minimal file with just the field we're testing
        new_gtfs[table_sym] = DataFrame(field => values)
    end
    return new_gtfs
end

"""
    create_gtfs_with_field(gtfs::GTFSSchedule, filename::String, field::Symbol, value) -> GTFSSchedule

Create a copy of GTFS with a specific field value for testing.
"""
function create_gtfs_with_field(gtfs::GTFSSchedule, filename::String, field::Symbol, value)
    new_gtfs = deepcopy(gtfs)
    table = replace(filename, r"\.(txt|geojson)$" => "")
    table_sym = Symbol(table)

    if haskey(new_gtfs, table_sym)
        df = new_gtfs[table_sym]
        df[!, field] = [value]
        new_gtfs[table_sym] = df
    end

    return new_gtfs
end

"""
    create_gtfs_without_file(gtfs::GTFSSchedule, file::String) -> GTFSSchedule

Create a copy of GTFS without a specific file for testing.
"""
function create_gtfs_without_file(gtfs::GTFSSchedule, file::String)
    new_gtfs = GTFSSchedule()
    # Convert filename to symbol (remove extension)
    file_sym = Symbol(replace(file, r"\.(txt|geojson)$" => ""))

    for (key, value) in gtfs
        if key != file_sym
            new_gtfs[key] = value
        end
    end
    return new_gtfs
end

end # module TestUtils
