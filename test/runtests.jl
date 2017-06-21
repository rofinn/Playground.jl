using Base.Test
# using Lint
using Mocking
Mocking.enable()

include("../src/Playground.jl")
using Playground
using FilePaths

TEST_DIR = cwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = join(TEST_DIR, p"tmp")
TEST_PLAYGROUND_DIR = join(TEST_TMP_DIR, p"playground")
TEST_CONFIG = load_config(DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)

mkdir(TEST_TMP_DIR; recursive=true, exist_ok=true)
mkdir(TEST_PLAYGROUND_DIR; recursive=true, exist_ok=true)

Playground.init(TEST_CONFIG)

# Order matters.
tests = [
    # "lint",
    "utils",
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
    include(join(TEST_DIR, Path(tfile)))
end


main(["install", "download", "0.5", "--labels", "julia-0.5"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["install", "link", joinpath(string(TEST_CONFIG.bin), "julia-0.5"), "--labels", "julia-stable-dir"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["create"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["exec", "ls -al", joinpath(string(TEST_DIR), ".playground")], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["list"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["clean"], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
main(["rm", "--dir", joinpath(string(TEST_DIR), ".playground")], DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)
