using Compat
using FilePaths
import Playground

# Get our current working path
deps_dir = parent(Path(@__FILE__))

# Setup the build directory
build_dir = join(deps_dir, "usr", "build")
mkdir(build_dir; recursive=true)

build_script = p"script.jl"

bin_exec = haskey(ENV, "PLAYGROUND_BIN_EXEC") ? parse(ENV["PLAYGROUND_BIN_EXEC"]) : false

if bin_exec
    # Actually build the playground executable
    info("Trying to build playground executable in $build_dir ...")
    using BuildExecutable
    build_executable(
        "playground",
        build_script,
        build_dir,
        "generic";
        force=true
    )
else
    info("Copying playground script to $build_dir")
    PKG_PLAYGROUND_BIN = join(deps_dir, "usr", "bin", "playground")
    copy(PKG_PLAYGROUND_BIN, join(build_dir, "playground"); exist_ok=true, overwrite=true)
    chmod(join(build_dir, "playground"), mode(PKG_PLAYGROUND_BIN))
end

config_file = join(build_dir, "config.yml")

info("Writing default config to $config_file.")
if exists(config_file)
    backup_file = join(build_dir, ".config.yml_$(Dates.today()).bak")
    info("Backing up existing config file to $backup_file")
    copy(config_file, backup_file; exist_ok=true, overwrite=true)
end

write(config_file, Playground.DEFAULT_CONFIG)

if is_unix()
    copy(
        join(deps_dir, "usr", "bin", "INSTALL.sh"),
        join(build_dir, "INSTALL.sh");
        exist_ok=true,
        overwrite=true
    )
end

copy(join(deps_dir, "..", "LICENSE"), join(build_dir, "LICENSE"); exist_ok=true, overwrite=true)
copy(join(deps_dir, "..", "README.md"), join(build_dir, "README.md"); exist_ok=true, overwrite=true)

# Only install the config and executable if the
# PLAYGROUND_INSTALL env variable has been set.
# This is just cause there isn't a `Pkg.install` or
# `Pkg.build("Pkg", install=true)`
install = haskey(ENV, "PLAYGROUND_INSTALL") ? parse(ENV["PLAYGROUND_INSTALL"]) : false

# Store our install paths
install_dir = Playground.config_path()
config_installed = join(install_dir, "config.yml")
playground_installed = join(install_dir, "bin", p"playground")
playground_compiled = join(build_dir, "playground")

if install
    # Set up the user level playground directory
    info("Setting up user playground directory...")
    mkdir(install_dir; recursive=true)
    mkdir(join(install_dir, p"bin"); recursive=true)

    info("Linking playground config to $config_installed.")

    if exists(config_installed)
        info("~/.playground/config.yml already exists. Skipping.")
        info("Please see $config_file if you have any problems with your existing config.yml file.")
    else
        symlink(config_file, config_installed; exist_ok=true, overwrite=true)
    end

    info("Linking playground executable to $playground_installed")

    if exist(playground_installed)
        backup_file = join(install_dir, "bin", ".playground_$(Dates.today()).bak")
        info("Backing up existing playground executable to $backup_file")
        copy(playground_installed, backup_file; exist_ok=true, overwrite=true)
    end

    symlink(playground_compiled, playground_installed; exist_ok=true, overwrite=true)

    info(
        "Adding $(join(install_dir, "bin")) to your PATH " *
        "variable will make `playground` and any julia versions installed via " *
        "Playground.jl available on your search path."
    )
else
    warn(
        "Compiled playground executable $playground_compiled " *
        "not installed to $playground_installed"
    )
end
