const DEFAULT_PLAYGROUND = "./.playground"
const DEFAULT_GIT_ADDRESS = "https://github.com/JuliaLang/julia.git"
const DEFAULT_GIT_REVISION = "master"
const DEFAULT_PROMPT_TEMPLATE = @windows ? "playground>" : "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m"
const DEFAULT_SHELL = ""
const DEFAULT_ISOLATE_SHELL_HISTORY = true
const DEFAULT_ISOLATE_JULIA_HISTORY = true

DECLARATIVE_PACKAGES_DIR = Pkg.dir("DeclarativePackages")
NIGHTLY = v"0.5-"

const DEFAULT_CONFIG = """
---
# Default playground directory. Used by `create` or `activate` when no name or
# directory parameter is given.
default_playground: \"$DEFAULT_PLAYGROUND\"

# Shell prompt when you activate a playground.
prompt: \"$(escape_string(DEFAULT_PROMPT_TEMPLATE))\"

# Shell to use when activating a playground.
# By default the environmental variable SHELL is used.
# default_shell: /usr/local/bin/fish

# Default git settings when using install build
default_git_address: \"$DEFAULT_GIT_ADDRESS\"
default_git_revision: $DEFAULT_GIT_REVISION

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: $DEFAULT_ISOLATE_SHELL_HISTORY
isolated_julia_history: $DEFAULT_ISOLATE_JULIA_HISTORY
"""
