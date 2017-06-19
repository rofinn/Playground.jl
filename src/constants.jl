DECLARATIVE_PACKAGES_DIR = Pkg.dir("DeclarativePackages")
DEFAULT_PROMPT = is_windows() ? "playground>" : "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m"
NIGHTLY = v"0.7-"
DEFAULT_CONFIG = """
---
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: .playground

# Default shell prompt when you activate a playground.
default_prompt: \"$(escape_string(DEFAULT_PROMPT))\"

# Uncomment below to change the default shell. Otherwise the SHELL
# Environment variable will be used.
# default_shell: /usr/local/bin/fish

# Default git settings when using install build
default_git_address: \"https://github.com/JuliaLang/julia.git\"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
"""
