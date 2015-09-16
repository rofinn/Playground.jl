DECLARATIVE_PACKAGES_DIR = Pkg.dir("DeclarativePackages")
CONFIG_PATH = joinpath(homedir(), ".playground")
@unix_only begin
    DEFAULT_PROMPT = "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m"
end
@windows_only begin
    DEFAULT_PROMPT = "playground>"
end

JULIA_DOWNLOADS_URL = "http://julialang.org/downloads/"
NIGHTLY = v"0.5"
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