
function test_create()
    create(
        TEST_CONFIG;
        dir=joinpath(TEST_TMP_DIR, "test-playground"),
        name="myproject",
        julia="julia-bin"
    )
    @test ispath(joinpath(TEST_TMP_DIR, "test-playground"))
    @test isdir(joinpath(TEST_TMP_DIR, "test-playground"))
    @test ispath(joinpath(TEST_PLAYGROUND_DIR, "share", "myproject"))
    @test islink(joinpath(TEST_PLAYGROUND_DIR, "share", "myproject"))

    create(TEST_CONFIG; name="otherproject")
    @test ispath(joinpath(TEST_PLAYGROUND_DIR, "share", "otherproject"))
    @test isdir(joinpath(TEST_PLAYGROUND_DIR, "share", "otherproject"))

    create(TEST_CONFIG)
    @test ispath(joinpath(TEST_DIR, ".playground"))
    @test isdir(joinpath(TEST_DIR, ".playground"))
end

test_create()
