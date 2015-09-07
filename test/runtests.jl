using Base.Test


include("../src/Playground.jl")
using Playground

test_dir = pwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = "$test_dir/tmp/"
TEST_PLAYGROUND_DIR = joinpath(TEST_TMP_DIR, "playground")
TEST_CONFIG = load_config(DEFAULT_CONFIG; root=TEST_PLAYGROUND_DIR)

tests = [
       "install",
       "activate",
]


println("Running tests:")


cd(TEST_TMP_DIR)
for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(joinpath(test_dir, tfile))
end

