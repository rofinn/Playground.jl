#Pkg.add("DeclarativePackages")
#symlink(Pkg.dir("DeclarativePackages")*"/bin/jdp",  "$(homedir())/local/bin/jdp")
BUILDFILE_PATH = @__FILE__
DEPS_PATH = dirname(BUILDFILE_PATH)
include(joinpath(DEPS_PATH), "../src/utils.jl")


mkpath(CONFIG_PATH)
mkpath(joinpath(CONFIG_PATH, "bin"))
PLAYGROUND_BIN = joinpath(CONFIG_PATH, "bin", "playground")


println("Writing default config.yml to $config_path.")

fstream = open(joinpath(CONFIG_PATH, "config.yml"), "w+")
write(fstream, DEFAULT_CONFIG)
close(fstream)

println("Linking playground script to $PLAYGROUND_BIN")
mklink(joinpath(DEPS_PATH), "usr/bin/playground"), PLAYGROUND_BIN)

println("Please add $(CONFIG_PATH)/bin to your PATH variable.")
