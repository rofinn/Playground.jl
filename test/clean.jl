function test_clean()
    remove(join(TEST_TMP_DIR, "test-playground"), recursive=true)
    @test !exists(join(TEST_TMP_DIR, "test-playground"))
    @test islink(join(TEST_CONFIG.bin, "julia-bin"))
    @test islink(join(TEST_CONFIG.share, "myproject"))

    clean(TEST_CONFIG)
    @test !exists(join(TEST_TMP_DIR, "test-playground"))
    @test islink(join(TEST_CONFIG.bin, "julia-bin"))
    @test !islink(join(TEST_CONFIG.share, "myproject"))
end


function test_rm()
    rm(TEST_CONFIG, dir=join(TEST_DIR, ".playground"))
    @test !exists(join(TEST_DIR, ".playground"))

    rm(TEST_CONFIG, name="julia-nightly-dir")
    @test !exists(join(TEST_CONFIG.bin, "julia-nightly-dir"))
end

test_clean()
test_rm()
