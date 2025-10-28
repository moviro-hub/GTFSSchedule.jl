# Pre-computed column type mappings for all GTFS tables
const COLUMN_TYPES_CACHE = Dict{Symbol, Dict{String, Type}}(
    table => Dict{String, Type}(string(def.field) => GTFS_TYPES[def.gtfs_type] for def in field_defs)
        for (table, field_defs) in FIELD_TYPES
)

"""
    read_gtfs(filepath::String) -> GTFSSchedule

Read a GTFS Schedule feed from a ZIP file or directory.

# Arguments
- `filepath::String`: Path to the GTFS ZIP file or directory containing GTFS files

# Returns
- `GTFSSchedule`: Dictionary mapping table names (as Symbols) to DataFrames

# Example
```julia
feed = read_gtfs("path/to/transit_feed.zip")
println("Number of agencies: ", nrow(feed[:agency]))
```

# Throws
- `ArgumentError`: If the file/directory doesn't exist or is not a valid GTFS source
"""
function read_gtfs(filepath::String, field_types::Dict{Symbol, Vector} = FIELD_TYPES)
    if !isfile(filepath) && !isdir(filepath)
        throw(ArgumentError("File or directory does not exist: $filepath"))
    end

    if isfile(filepath)
        if !endswith(filepath, ".zip")
            throw(ArgumentError("File must be a ZIP archive: $filepath"))
        end
        return _read_gtfs_from_zip(filepath, field_types)
    elseif isdir(filepath)
        return _read_gtfs_from_directory(filepath, field_types)
    else
        throw(ArgumentError("Path must be either a ZIP file or directory: $filepath"))
    end
end

function _read_gtfs_from_zip(filepath::String, field_types::Dict{Symbol, Vector})
    # Extract ZIP file to temporary directory
    temp_dir = mktempdir()
    try
        # Use system unzip command
        run(`unzip -q $filepath -d $temp_dir`)

        # Get list of files in the extracted directory
        files = readdir(temp_dir)

        # Handle case where ZIP contains a subdirectory
        if length(files) == 1 && isdir(joinpath(temp_dir, files[1]))
            temp_dir = joinpath(temp_dir, files[1])
        end

        # Read GTFS data from the directory
        return _read_gtfs_from_directory(temp_dir, field_types)
    finally
        # Clean up temp directory
        try
            rm(temp_dir, recursive = true, force = true)
        catch
            # Ignore cleanup errors
        end
    end
end

function _read_gtfs_from_directory(dirpath::String, field_types::Dict{Symbol, Vector})
    if !isdir(dirpath)
        throw(ArgumentError("Directory does not exist: $dirpath"))
    end

    # Get list of all files in directory
    all_files = readdir(dirpath)
    gtfs_files = filter(f -> endswith(f, ".txt") || endswith(f, ".geojson"), all_files)

    if isempty(gtfs_files)
        throw(ArgumentError("Directory does not contain any GTFS files (.txt or .geojson): $dirpath"))
    end

    # Read all available GTFS files
    feed = GTFSSchedule()

    for filename in gtfs_files
        filepath = joinpath(dirpath, filename)
        # Convert filename to Symbol key (remove extension) - parse once
        table = Symbol(replace(filename, r"\.(txt|geojson)$" => ""))
        try
            # Route to appropriate parser based on file extension
            if endswith(filename, ".geojson")
                df = _read_geojson_file(filepath)
            else
                df = _read_csv_file(filepath, table, field_types)
            end
            feed[table] = df
        catch e
            @warn "Error reading $filename: $e"
            feed[table] = nothing
        end
    end

    return feed
end

function _read_csv_file(filepath::String, table::Symbol, field_types::Dict{Symbol, Vector})
    column_types = get(COLUMN_TYPES_CACHE, table, Dict{String, Type}())
    return CSV.read(
        filepath,
        DataFrames.DataFrame;
        silencewarnings = true,
        strict = false,
        missingstring = ["", "NA", "N/A", "null"],
        types = column_types,
        stringtype = String,
        validate = false
    )
end

function _read_geojson_file(filepath::String)
    # Read the GeoJSON file using GeoJSON.jl as DataFrame
    return DataFrames.DataFrame(GeoJSON.read(filepath))
end
