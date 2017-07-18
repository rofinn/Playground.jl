using Documenter, Playground

makedocs(
    format = :html,
    sitename = "Playground.jl",
    modules = [Playground],
    assets = ["assets/playground.css"],
    pages = [
        "index.md",
        "binaries.md",
        "executable.md",
        "repl.md",
        "api.md",
    ]
)

deploydocs(
    repo = "github.com/rofinn/Playground.jl.git",
    target = "build",
    julia  = "0.6",
    deps = nothing,
    make = nothing
)
