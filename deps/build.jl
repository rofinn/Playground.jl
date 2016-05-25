using BuildExecutable
import Playground

# Get our current working path
deps_dir = dirname(@__FILE__)

# Setup the build directory
build_dir = joinpath(deps_dir, "usr", "build")
mkpath(build_dir)

build_script = "script.jl"

# Actually build the playground executable
info("Trying to build playground executable in $build_dir ...")
build_executable(
    "playground",
    build_script,
    build_dir,
    "generic"; force=true
)

config_file = joinpath(build_dir, "config.yml")

info("Writing default config to $config_file.")
if ispath(config_file)
    backup_file = joinpath(build_dir, ".config.yml_$(Dates.today()).bak")
    info("Backing up existing config file to $backup_file")
    Playground.copy(config_file, backup_file)
end

open(config_file, "w+") do fstream
    write(fstream, Playground.DEFAULT_CONFIG)
end

@unix_only begin
    Playground.copy(joinpath(deps_dir, "usr", "bin", "INSTALL.sh"), joinpath(build_dir, "INSTALL.sh"))
end

Playground.copy(joinpath(deps_dir, "..", "LICENSE"), joinpath(build_dir, "LICENSE"))
Playground.copy(joinpath(deps_dir, "..", "README.md"), joinpath(build_dir, "README.md"))

# Only install the config and executable if the
# PLAYGROUND_INSTALL env variable has been set.
# This is just cause there isn't a `Pkg.install` or
# `Pkg.build("Pkg", install=true)`
install = haskey(ENV, "PLAYGROUND_INSTALL")

# Store our install paths
install_dir = Playground.config_path()
config_installed = joinpath(install_dir, "config.yml")
playground_installed = joinpath(install_dir, "bin", "playground")
playground_compiled = joinpath(build_dir, "playground")

if install
    # Set up the user level playground directory
    info("Setting up user playground directory...")
    mkpath(install_dir)
    mkpath(joinpath(install_dir, "bin"))

    info("Linking playground config to $config_installed.")

    if ispath(config_installed)
        info("~/.playground/config.yml already exists. Skipping.")
        info("Please see $config_file if you have any problems with your existing config.yml file.")
    else
        Playground.mklink(config_file, config_installed)
    end

    info("Linking playground executable to $playground_installed")

    if ispath(playground_installed)
        backup_file = joinpath(install_dir, "bin", ".playground_$(Dates.today()).bak")
        info("Backing up existing playground executable to $backup_file")
        Playground.copy(playground_installed, backup_file)
    end

    Playground.mklink(playground_compiled, playground_installed)

    info(
        "Adding $(joinpath(install_dir, "bin")) to your PATH " *
        "variable will make `playground` and any julia versions installed via" *
        "Playground.jl available on your search path."
    )
else
    warn(
        "Compiled playground executable $playground_compiled " *
        "not installed to $playground_installed"
    )
end
