using BuildExecutable


# Get our current working path
BUILDFILE_PATH = @__FILE__
DEPS_PATH = dirname(BUILDFILE_PATH)

# Only install the config and executable if the
# PLAYGROUND_INSTALL env variable has been set.
# This is just cause there isn't a `Pkg.install` or
# `Pkg.build("Pkg", install=true)`
INSTALL = haskey(ENV, "PLAYGROUND_INSTALL")

include(joinpath(DEPS_PATH, "../src/Playground.jl"))

# Store our install paths
INSTALL_CONFIG = joinpath(Playground.CONFIG_PATH, "config.yml")
INSTALL_PLAYGROUND_EXEC = joinpath(Playground.CONFIG_PATH, "bin/playground")

# Set up the user level playground directory
mkpath(Playground.CONFIG_PATH)
mkpath(joinpath(Playground.CONFIG_PATH, "bin"))

# Get the playground script path
PLAYGROUND_SCRIPT = joinpath(DEPS_PATH, "usr/bin/playground")
BUILD_PATH = joinpath(DEPS_PATH, "usr/build/")
mkpath(BUILD_PATH)

# Actually build the playground executable
build_executable(
    "playground",
    PLAYGROUND_SCRIPT,
    BUILD_PATH,
    "core2"; force=true
)

config_file = joinpath(Playground.CONFIG_PATH, "config.yml")

if INSTALL
    info("Writing default config to $(Playground.CONFIG_PATH)/config.yml.")
    config_file = joinpath(Playground.CONFIG_PATH, "config.yml")

    if ispath(config_file)
        backup_file = joinpath(Playground.CONFIG_PATH, ".config.yml_$(Dates.today()).bak")
        info("Backing up existing config file to $backup_file")
        Playground.copy(config_file, backup_file)
    end

    fstream = open(joinpath(Playground.CONFIG_PATH, "config.yml"), "w+")
    write(fstream, Playground.DEFAULT_CONFIG)
    close(fstream)

    info("Linking playground executable to $INSTALL_PLAYGROUND_EXEC")

    if ispath(INSTALL_PLAYGROUND_EXEC)
        backup_file = joinpath(Playground.CONFIG_PATH, "bin", ".playground_$(Dates.today()).bak")
        info("Backing up existing playground executable to $backup_file")
        Playground.copy(INSTALL_PLAYGROUND_EXEC, backup_file)
    end

    Playground.mklink(joinpath(BUILD_PATH, "playground"), INSTALL_PLAYGROUND_EXEC)

    info(string(
        "Adding $(Playground.CONFIG_PATH)/bin to your PATH ",
        "variable will make `playground` and any julia versions installed via",
        "Playground.jl available on your search path."
    ))
else
    if !ispath(config_file)
        info("Writing default config to $(Playground.CONFIG_PATH)/config.yml.")
        fstream = open(joinpath(Playground.CONFIG_PATH, "config.yml"), "w+")
        write(fstream, Playground.DEFAULT_CONFIG)
        close(fstream)
    end

    warn(string(
        "Compiled playground executable $(BUILD_PATH)/playground ",
        "not installed to $INSTALL_PLAYGROUND_EXEC"
    ))
end




