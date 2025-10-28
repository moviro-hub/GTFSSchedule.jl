"""
    DatasetFile

Represents a GTFS file from the Dataset Files section.
"""
struct DatasetFile
    filename::String
    presence::String
    description::String
end

"""
    parse_dataset_files(lines::Vector{String}, presence_types::Vector{Presence}) -> Vector{DatasetFile}

Parse dataset files from the "Dataset Files" section.
"""
function parse_dataset_files(lines::Vector{String}, presence_types::Vector{Presence})
    files = DatasetFile[]
    in_section = false
    table_started = false

    for (i, line) in enumerate(lines)
        stripped = strip(line)

        # Check for section start
        if is_header(line, "Dataset Files", 2)
            in_section = true
            continue
        end

        # Check for section end
        if in_section && is_boundary(line, 2) && !occursin("Dataset Files", stripped)
            break
        end

        if !in_section
            continue
        end

        # Find table start
        if !table_started
            table_info = find_table(lines, i, 10)
            if table_info !== nothing
                table_started = true
                continue
            end
        end

        # Parse table rows
        if table_started && startswith(stripped, "|")
            dataset_file = parse_dataset_row(line, presence_types)
            if dataset_file !== nothing
                push!(files, dataset_file)
            end
        end
    end

    return files
end

function parse_dataset_row(line::String, presence_types::Vector{Presence})
    row = parse_row(line, true)
    if row === nothing || length(row) < 3
        return nothing
    end

    filename = strip_link(row[1])
    presence = normalize_presence_type(row[2], presence_types)
    description = row[3]

    if !isempty(filename) && !isempty(presence)
        return DatasetFile(filename, presence, description)
    end

    return nothing
end
