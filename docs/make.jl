using Documenter, GTFSSchedules

# Set up the documentation environment
makedocs(;
    sitename = "GTFSSchedules.jl",
    authors = "MOVIRO",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://moviro-hub.github.io/GTFSSchedules.jl",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
        "Examples" => "examples.md",
    ],
    checkdocs = :exports,
)

deploydocs(;
    repo = "github.com/moviro-hub/GTFSSchedules.jl.git",
    target = "build",
    branch = "gh-pages",
    devbranch = "main",
)
