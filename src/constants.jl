const DECLARATIVE_PACKAGES_DIR = Pkg.dir("DeclarativePackages")
const NIGHTLY = v"1.3.0-"
const JULIA_BIN_MODE = Mode(user=(READ+WRITE+EXEC), group=(READ+EXEC), other=(READ+EXEC))
const DEFAULT_CONFIG = """
---
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: .playground

# Uncomment below to change the default shell. Otherwise the SHELL
# Environment variable will be used.
# default_shell: /usr/local/bin/fish

# Default julia registry settings.
default_registry: \"https://github.com/JuliaLang/METADATA.jl.git\"
default_branch: \"metadata-v2\"

# Default git settings when using install build
default_git_address: \"https://github.com/JuliaLang/julia.git\"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
"""
