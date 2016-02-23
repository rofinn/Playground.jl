# Playground creation with no specified root and no global name
let root_dir = Playground.CORE.default_playground
    cd(TMP_DIR) do
        @test !ispath(root_dir)

        playground = Playground.create_playground()

        @test abspath(playground.root) == abspath(root_dir)
        @test isdir(playground.root)
        @test isdir(playground.pkg_dir)
        @test isdir(playground.bin_dir)
        @test isexecutable(playground.julia_path)

        @test length(readdir(Playground.CORE.share_dir)) == 0
        @test Playground.playground_name(root_dir) == nothing

        Playground.remove(playground)
        @test !ispath(root_dir)
    end
end

# Playground creation with a specified root and no global name
let root_dir = joinpath(TMP_DIR, "playground")
    @test !ispath(root_dir)

    playground = Playground.create_playground(
        root=root_dir,
    )

    @test abspath(playground.root) == abspath(root_dir)
    @test isdir(playground.root)
    @test isdir(playground.pkg_dir)
    @test isdir(playground.bin_dir)
    @test isexecutable(playground.julia_path)

    @test length(readdir(Playground.CORE.share_dir)) == 0
    @test Playground.playground_name(root_dir) == nothing

    Playground.remove(playground)
    @test !ispath(root_dir)
end

# Playground creation with no specified root but a global name
let name = "test", root_dir = joinpath(Playground.CORE.share_dir, name)
    @test !ispath(root_dir)

    playground = Playground.create_playground(
        name=name,
    )

    @test abspath(playground.root) == abspath(root_dir)
    @test isdir(playground.root)
    @test isdir(playground.pkg_dir)
    @test isdir(playground.bin_dir)
    @test isexecutable(playground.julia_path)

    @test Playground.playground_name(root_dir) == name
    @test Playground.playground_dir(name) == root_dir

    Playground.remove(playground)

    @test !ispath(root_dir)
    @test Playground.playground_name(root_dir) == nothing
    @test Playground.playground_dir(name) == nothing
end

# Playground creation with a specified root and a global name
let name = "test", root_dir = joinpath(TMP_DIR, "playground")
    @test !ispath(root_dir)

    playground = Playground.create_playground(
        root=root_dir,
        name=name,
    )

    @test abspath(playground.root) == abspath(root_dir)
    @test isdir(playground.root)
    @test isdir(playground.pkg_dir)
    @test isdir(playground.bin_dir)
    @test isexecutable(playground.julia_path)

    @test Playground.playground_name(root_dir) == name
    @test Playground.playground_dir(name) == root_dir

    Playground.remove(playground)

    @test !ispath(root_dir)
    @test Playground.playground_name(root_dir) == nothing
    @test Playground.playground_dir(name) == nothing
end

# Playground created with a REQUIRE file
let name = "require", root_dir = joinpath(TMP_DIR, "playground")
    playground = Playground.create_playground(
        root=root_dir,
        name=name,
        reqs_file="REQUIRE",
    )

    version_str = "v0.4"
    @test isfile(joinpath(playground.pkg_dir, version_str, "REQUIRE"))
    @test isdir(joinpath(playground.pkg_dir, version_str, "DeclarativePackages"))
    @test isdir(joinpath(playground.pkg_dir, version_str, "Mocking"))

    Playground.remove(playground)
end

# Playground created with a DECLARE file
let name = "declare", root_dir = joinpath(TMP_DIR, "playground")
    last_modified = stat("DECLARE").mtime

    playground = Playground.create_playground(
        root=root_dir,
        name=name,
        reqs_file="DECLARE",
        reqs_type=:DECLARE,
    )

    # Check that original DECLARE file was not modified
    @test stat("DECLARE").mtime == last_modified

    version_str = "v0.4"
    @test isfile(joinpath(playground.pkg_dir, version_str, "DECLARE"))

    # TODO: Check specific versions installed
    @test isdir(joinpath(playground.pkg_dir, version_str, "JSON"))
    @test isdir(joinpath(playground.pkg_dir, version_str, "SHA"))

    Playground.remove(playground)
end


# TODO: requirements, specify julia


# function create_playground(; root::AbstractString="", name::AbstractString="",
#     julia::AbstractString="", reqs_file::AbstractString="", reqs_type::Symbol=:REQUIRE)


# create(
#     TEST_CONFIG;
#     dir=joinpath(TEST_TMP_DIR, "test-playground"),
#     name="myproject",
#     reqs_file=joinpath(TEST_DIR, "../REQUIRE"),
#     julia="julia-bin"
# )
# @test ispath(joinpath(TEST_TMP_DIR, "test-playground"))
# @test isdir(joinpath(TEST_TMP_DIR, "test-playground"))
# @test ispath(joinpath(TEST_CONFIG.dir.store, "myproject"))
# @test islink(joinpath(TEST_CONFIG.dir.store, "myproject"))

#     create(
#         TEST_CONFIG;
#         name="otherproject",
#         reqs_file=joinpath(TEST_DIR, "DECLARE"),
#         reqs_type=:DECLARE,
#         julia="julia-nightly-dir"
#     )

#     @test ispath(joinpath(TEST_CONFIG.dir.store, "otherproject"))
#     @test isdir(joinpath(TEST_CONFIG.dir.store, "otherproject"))

#     create(TEST_CONFIG)
#     @test ispath(joinpath(TEST_DIR, ".playground"))
#     @test isdir(joinpath(TEST_DIR, ".playground"))
# end

# test_create()
