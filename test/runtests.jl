using Base.Test
using Lint
using Mocking

include("../src/Playground.jl")
using Playground

TEST_DIR = pwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = "$TEST_DIR/tmp/"
TEST_PLAYGROUND_DIR = joinpath(TEST_TMP_DIR, "playground")
TEST_CONFIG = load_config(DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)

mkpath(TEST_TMP_DIR)
mkpath(TEST_PLAYGROUND_DIR)

Playground.init(TEST_CONFIG)

# Order matters.
tests = [
    "lint",
    "list",
    "parsing",
    "install",
    "create",
    "activate",
    "execute",
    "clean"
]


println("Running tests:")


for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(joinpath(TEST_DIR, tfile))
end


main(["install", "download", "0.4", "--labels", "julia-0.3"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["install", "link", joinpath(TEST_CONFIG.dir.bin, "julia-0.3"), "--labels", "julia-stable-dir"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["create"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["exec", "ls -al", joinpath(TEST_DIR, ".playground")], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["list"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["clean"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["rm", "--dir", joinpath(TEST_DIR, ".playground")], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
