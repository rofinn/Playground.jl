using BuildExecutable


# Get our current working path
buildfile_path = @__FILE__
deps_path = dirname(buildfile_path)

include(joinpath(deps_path, "../src/Playground.jl"))

# Get the playground script path
playground_script = joinpath(deps_path, "usr/bin/playground")
build_path = joinpath(deps_path, "usr/build/")
config_file = joinpath(build_path, "config.yml")
mkpath(build_path)

# Actually build the playground executable
info("Trying to build playground executable in $(build_path) ...")
build_executable(
    "playground",
    playground_script,
    build_path,
    "generic"; force=true
)

info("Writing default config to $config_file.")
if ispath(config_file)
    backup_file = joinpath(build_path, ".config.yml_$(Dates.today()).bak")
    info("Backing up existing config file to $backup_file")
    Playground.copy(config_file, backup_file)
end

fstream = open(config_file, "w+")
write(fstream, Playground.DEFAULT_CONFIG)
close(fstream)

@unix_only begin
    Playground.copy(joinpath(deps_path, "usr/bin/INSTALL.sh"), joinpath(build_path, "INSTALL.sh"))
end

Playground.copy(joinpath(deps_path, "../LICENSE"), joinpath(build_path, "LICENSE"))
Playground.copy(joinpath(deps_path, "../README.md"), joinpath(build_path, "README.md"))

# Only install the config and executable if the
# PLAYGROUND_INSTALL env variable has been set.
# This is just cause there isn't a `Pkg.install` or
# `Pkg.build("Pkg", install=true)`
install = haskey(ENV, "PLAYGROUND_INSTALL")
# Store our install paths
install_path = Playground.config_path()
install_config = joinpath(install_path, "config.yml")
install_playground_exec = joinpath(install_path, "bin", "playground")

if install
    # Set up the user level playground directory
    info("Setting up user playground directory...")
    mkpath(install_path)
    mkpath(joinpath(install_path, "bin"))

    info("Linking playground config to $install_path/config.yml.")

    if ispath(install_config)
        info("~/.playground/config.yml already exists. Skipping.")
        info("Please see $config_file if you have any problems with your existing config.yml file.")
    else
        Playground.mklink(config_file, install_config)
    end

    info("Linking playground executable to $install_playground_exec")

    if ispath(install_playground_exec)
        backup_file = joinpath(install_path, "bin", ".playground_$(Dates.today()).bak")
        info("Backing up existing playground executable to $backup_file")
        Playground.copy(install_playground_exec, backup_file)
    end

    Playground.mklink(joinpath(build_path, "playground"), install_playground_exec)

    info(string(
        "Adding $install_path/bin to your PATH ",
        "variable will make `playground` and any julia versions installed via",
        "Playground.jl available on your search path."
    ))
else
    warn(string(
        "Compiled playground executable $(build_path)/playground ",
        "not installed to $install_playground_exec"
    ))
end




