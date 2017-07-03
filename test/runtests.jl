using Base.Test
# using Lint
using Mocking
Mocking.enable()

include("../src/Playground.jl")
using Playground
using FilePaths
using Memento

Memento.config("debug"; fmt="[ {level} ] {msg}")

TEST_DIR = cwd()

#TEST_TMP_DIR = mktempdir("../test/")
TEST_TMP_DIR = join(TEST_DIR, p"tmp")
TEST_PLAYGROUND_DIR = join(TEST_TMP_DIR, p"playground")
TEST_CONFIG = Config(DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)

mkdir(TEST_TMP_DIR; recursive=true, exist_ok=true)
mkdir(TEST_PLAYGROUND_DIR; recursive=true, exist_ok=true)

Playground.init(TEST_CONFIG)

# Order matters.
tests = [
    # "lint",
    # "utils",
    # "list",
    # "parsing",
    # "install",
    # "create",
    "activate",
    "execute",
    # "clean"
]


println("Running tests:")


for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(join(TEST_DIR, Path(tfile)))
end

test_main(args) = main(args, DEFAULT_CONFIG, TEST_PLAYGROUND_DIR)

test_main(["--debug", "install", "download", "0.5", "--labels", "julia-0.5"])
test_main(["--debug", "install", "link", join(string(TEST_CONFIG.bin), "julia-0.5"), "--labels", "julia-stable-dir"])
test_main(["--debug", "create"])
test_main(["--debug", "exec", "ls -al", join(string(TEST_DIR), ".playground")])
test_main(["--debug", "list"])
test_main(["--debug", "clean"])
test_main(["--debug", "rm", "--dir", join(string(TEST_DIR), ".playground")])
