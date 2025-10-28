"""
    Download

Module for downloading the official GTFS specification from GitHub.

This module provides functions to download the latest GTFS specification
markdown file from the official Google Transit repository. It handles
error cases and provides clear feedback on download status.
"""
module Download

# Constants
const DEFAULT_FILENAME = "gtfs_reference.md"
const GTFS_SPEC_URL = "https://raw.githubusercontent.com/google/transit/master/gtfs/spec/en/reference.md"

"""
    download_gtfs_spec(output_file::String=DEFAULT_FILENAME) -> String

Download the official Google Transit GTFS reference markdown file.

# Arguments
- `output_file::String`: Path where to save the downloaded file (default: "gtfs_reference.md")

# Returns
- `String`: Path to the downloaded file

# Throws
- `ErrorException`: If download fails
"""
function download_gtfs_spec(output_file::String = DEFAULT_FILENAME)
    println("Downloading GTFS specification from: $GTFS_SPEC_URL")

    try
        # Use Julia's built-in download function
        download(GTFS_SPEC_URL, output_file)
        println("Successfully downloaded GTFS specification to: $output_file")
        return output_file
    catch e
        error("Failed to download GTFS specification from $GTFS_SPEC_URL: $e")
    end
end

"""
    download_gtfs_spec_to_dir(directory::String=".") -> String

Download the GTFS specification to a specific directory.

# Arguments
- `directory::String`: Directory to save the file in (default: current directory)

# Returns
- `String`: Full path to the downloaded file
"""
function download_gtfs_spec_to_dir(directory::String = ".")
    # Ensure directory exists
    if !isdir(directory)
        mkpath(directory)
    end

    output_file = joinpath(directory, DEFAULT_FILENAME)
    return download_gtfs_spec(output_file)
end


end
