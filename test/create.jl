
function test_create()
    create(
        TEST_CONFIG;
        dir=joinpath(TEST_TMP_DIR, "test-playground"),
        name="myproject",
        reqs_file=joinpath(TEST_DIR, "../REQUIRE"),
        julia="julia-bin"
    )
    @test ispath(joinpath(TEST_TMP_DIR, "test-playground"))
    @test isdir(joinpath(TEST_TMP_DIR, "test-playground"))
    @test ispath(joinpath(TEST_CONFIG.dir.store, "myproject"))
    @test islink(joinpath(TEST_CONFIG.dir.store, "myproject"))

    create(TEST_CONFIG)
    @test ispath(joinpath(TEST_DIR, ".playground"))
    @test isdir(joinpath(TEST_DIR, ".playground"))
end

test_create()
