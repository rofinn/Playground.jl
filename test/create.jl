
function test_create()
    create(
        TEST_CONFIG,
        join(TEST_TMP_DIR, "test-playground"),
        "myproject";
        reqs_file=join(TEST_DIR, "../REQUIRE"),
        julia="julia-bin"
    )
    @test exists(join(TEST_TMP_DIR, "test-playground"))
    @test isdir(join(TEST_TMP_DIR, "test-playground"))
    @test exists(join(TEST_CONFIG.share, "myproject"))
    @test islink(join(TEST_CONFIG.share, "myproject"))

    create(TEST_CONFIG)
    @test exists(join(TEST_DIR, ".playground"))
    @test isdir(join(TEST_DIR, ".playground"))
end

test_create()
