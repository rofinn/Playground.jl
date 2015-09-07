CONFIG_PATH = joinpath(homedir(), ".playground")
DEFAULT_PROMPT = "\\e[0;35m\\u@\\h (playground)> \\e[m"
DEFAULT_CONFIG = """
---
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: .playground

# Default shell prompt when you activate a playground.
default_prompt: \"$(escape_string(DEFAULT_PROMPT))\"

# Default git settings when using install build
default_git_address: \"https://github.com/JuliaLang/julia.git\"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
"""


@osx_only begin
    binfiles = Dict(
        v"0.4" => "julia-0.4.0-pre-osx",
        v"0.3" => "julia-0.3.11-osx"
    )
    suffix_binurls = Dict(
        v"0.4" => "osx10.7+",
        v"0.3" => "osx/x64/0.3/julia-0.3.11-osx10.7+.dmg",
    )
end

@linux_only begin
    binfiles = Dict(
        v"0.4" => "julia-0.4.0-pre-linux",
        v"0.3" => "julia-0.3.11-linux"
    )

    suffix_binurls = Dict(
        v"0.4" => "linux-x86_64",
        v"0.3" => "linux/x64/0.3/julia-0.3.11-linux-x86_64.tar.gz",
    )
end

@windows_only begin
    binfiles = Dict(
        v"0.4" => "julia-0.4.0-pre-win64",
        v"0.3" => "julia-0.3.11-win64"
    )
    suffix_binurls = Dict(
        v"0.4" => "win64",
        v"0.3" => "winnt/x64/0.3/julia-0.3.11-win64.exe",
    )
end

binurls = Dict(
    v"0.4" => "https://status.julialang.org/download/" * suffix_binurls[v"0.4"],
    v"0.3" => "https://s3.amazonaws.com/julialang/bin/" * suffix_binurls[v"0.3"],
)

