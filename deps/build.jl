using Logging

Logging.configure(level=Logging.INFO)

BUILDFILE_PATH = @__FILE__
DEPS_PATH = dirname(BUILDFILE_PATH)
JULIA_PATH = ENV["_"]

include(joinpath(DEPS_PATH, "../src/Playground.jl"))

mkpath(Playground.CONFIG_PATH)
mkpath(joinpath(Playground.CONFIG_PATH, "bin"))
PLAYGROUND_BIN = joinpath(Playground.CONFIG_PATH, "bin", "playground")
PKG_PLAYGROUND_BIN = joinpath(DEPS_PATH, "usr/bin/playground")


Logging.info("Writing default config to $(Playground.CONFIG_PATH)/config.yml.")
config_file = joinpath(Playground.CONFIG_PATH, "config.yml")

if ispath(config_file)
    backup_file = joinpath(Playground.CONFIG_PATH, ".config.yml_$(Dates.today()).bak")
    Logging.info("Backing up existing config file to $backup_file")
    Playground.copy(config_file, backup_file)
end

fstream = open(joinpath(Playground.CONFIG_PATH, "config.yml"), "w+")
write(fstream, Playground.DEFAULT_CONFIG)
close(fstream)

Logging.info("Installing playground script to PLAYGROUND_BIN")

if ispath(PLAYGROUND_BIN)
    backup_file = joinpath(Playground.CONFIG_PATH, "bin", ".playground_$(Dates.today()).bak")
    Logging.info("Backing up existing playground script to $backup_file")
    Playground.copy(PLAYGROUND_BIN, backup_file)
end

#=
Dynamically set the shebang in the playground script.
This is necessary for several reasons:
    1. /usr/bin/env will stall if we want to include the `--depwarn=noe`
    2. people may have their default julia version installed in weird locations
    3. chances are that people will want playground to use the same julia environment that they installed it from.
=#
Logging.warn("Playground using julia environment: $(JULIA_PATH). Modify the shebang in $PLAYGROUND_BIN to change this behaviour.")
script = readall(PKG_PLAYGROUND_BIN)

fstream = open(PLAYGROUND_BIN, "w+")
seek(fstream, 0)
write(fstream, "#!$(JULIA_PATH) --depwarn=no\n\n$(script)")
close(fstream)

chmod(PLAYGROUND_BIN, filemode(PKG_PLAYGROUND_BIN))

Logging.info("Please add $(Playground.CONFIG_PATH)/bin to your PATH variable.")
