const DECLARATIVE_PACKAGES_DIR = Pkg.dir("DeclarativePackages")
const REPL_PROMPT = "playground>"
const SHELL_PROMPT = if is_windows()
    "playground>"
elseif contains(get(ENV, "SHELL", ""), "zsh")
    "%F{5}%n@%m:%~ (playground)> %f"
else
    "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m"
end
const NIGHTLY = v"0.7-"
const JULIA_BIN_MODE = Mode(user=(READ+WRITE+EXEC), group=(READ+EXEC), other=(READ+EXEC))
const DEFAULT_CONFIG = """
---
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: .playground

# Default repl prompt when you activate a playground environment.
repl_prompt: $REPL_PROMPT

# Default shell prompt when you activate a playground environment.
shell_prompt: \"$(escape_string(SHELL_PROMPT))\"

default_prompt: \"$(escape_string(SHELL_PROMPT))\"

# Uncomment below to change the default shell. Otherwise the SHELL
# Environment variable will be used.
# default_shell: /usr/local/bin/fish

# Default julia metadata settings.
default_julia_metadata: \"https://github.com/JuliaLang/METADATA.jl.git\"
default_julia_meta_branch: \"metadata-v2\"

# Default git settings when using install build
default_git_address: \"https://github.com/JuliaLang/julia.git\"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
"""
