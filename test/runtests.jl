using Compat
using Base.Test

VERSION < v"0.4-" && using Docile


include("../src/Playground.jl")
using Playground

TEST_DIR = pwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = "$TEST_DIR/tmp/"
TEST_PLAYGROUND_DIR = joinpath(TEST_TMP_DIR, "playground")
TEST_CONFIG = load_config(DEFAULT_CONFIG; root=TEST_PLAYGROUND_DIR)

mkpath(TEST_TMP_DIR)
mkpath(TEST_PLAYGROUND_DIR)

tests = [
   "install",
   "create",
   "activate",
   "list"
]


println("Running tests:")


for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(joinpath(TEST_DIR, tfile))
end

