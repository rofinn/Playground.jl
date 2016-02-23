using Base.Test
# using Mocking

using Playground

TMP_DIR = joinpath(pwd(), "tmp")
isdir(TMP_DIR) && rm(TMP_DIR, recursive=true)  # Cleanup previous test runs
mkpath(TMP_DIR)

# Setup a temporary core for testing
core_dir = joinpath(TMP_DIR, "core")
Playground.set_core(Playground.init!(Playground.PlaygroundCore(core_dir)))

# Verify the new core was succesfully created
@test Playground.CORE.root_dir == core_dir
@test isdir(Playground.CORE.root_dir)
@test isdir(Playground.CORE.tmp_dir)
@test isdir(Playground.CORE.src_dir)
@test isdir(Playground.CORE.bin_dir)
@test isdir(Playground.CORE.share_dir)
@test isfile(joinpath(Playground.CORE.root_dir, "config.yml"))



# Order matters.
tests = [
    "utils",
    "list",
    "args",
    "install",
    "create",
    "activate",
    "execute",
    "clean",
]


println("Running tests:")


for name in tests
    test_file = "$(name).jl"
    println(" * $test_file ...")
    include(test_file)
end


playground_dir = joinpath(TMP_DIR, ".playground")
Playground.main(["install", "download", "0.4+", "--labels", "julia-0.3"])
Playground.main(["install", "link", joinpath(Playground.CORE.bin_dir, "julia-0.3"), "--labels", "julia-stable-dir"])
Playground.main(["create", playground_dir])
Playground.main(["exec", playground_dir, "ls -al"])
Playground.main(["list"])
Playground.main(["clean"])
Playground.main(["rm", playground_dir])
