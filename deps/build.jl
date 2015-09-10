BUILDFILE_PATH = @__FILE__
DEPS_PATH = dirname(BUILDFILE_PATH)

include(joinpath(DEPS_PATH, "../src/Playground.jl"))


mkpath(Playground.CONFIG_PATH)
mkpath(joinpath(Playground.CONFIG_PATH, "bin"))
PLAYGROUND_BIN = joinpath(Playground.CONFIG_PATH, "bin", "playground")


println("Writing default config.yml to $Playground.CONFIG_PATH.")

fstream = open(joinpath(Playground.CONFIG_PATH, "config.yml"), "w+")
write(fstream, Playground.DEFAULT_CONFIG)
close(fstream)

println("Linking playground script to $PLAYGROUND_BIN")
Playground.mklink(joinpath(DEPS_PATH, "usr/bin/playground"), PLAYGROUND_BIN)

println("Please add $(Playground.CONFIG_PATH)/bin to your PATH variable.")
