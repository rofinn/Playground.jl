VERSION < v"0.4-" && using Docile

using Compat
using Base.Test
using Lint

include("../src/Playground.jl")
using Playground

# Run lint Playground.jl for Error or Critical level message
msgs = lintpkg("Playground", returnMsgs=true)
for m in msgs
    @test m.level < 2
end

TEST_DIR = pwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = "$TEST_DIR/tmp/"
TEST_PLAYGROUND_DIR = joinpath(TEST_TMP_DIR, "playground")
TEST_CONFIG = load_config(DEFAULT_CONFIG; root=TEST_PLAYGROUND_DIR)

mkpath(TEST_TMP_DIR)
mkpath(TEST_PLAYGROUND_DIR)

# Order matters.
tests = [
    "parsing",
    "install",
    "create",
    "activate",
    "list",
    "clean"
]


println("Running tests:")


for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(joinpath(TEST_DIR, tfile))
end

