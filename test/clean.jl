function test_clean()
    rm(joinpath(TEST_TMP_DIR, "test-playground"), recursive=true)
    @test !ispath(joinpath(TEST_TMP_DIR, "test-playground"))
    @test islink(joinpath(TEST_CONFIG.bin, "julia-bin"))
    @test islink(joinpath(TEST_CONFIG.share, "myproject"))

    clean(TEST_CONFIG)
    @test !ispath(joinpath(TEST_TMP_DIR, "test-playground"))
    @test islink(joinpath(TEST_CONFIG.bin, "julia-bin"))
    @test !islink(joinpath(TEST_CONFIG.share, "myproject"))
end


function test_rm()
    rm(TEST_CONFIG, dir=joinpath(TEST_DIR, ".playground"))
    @test !ispath(joinpath(TEST_DIR, ".playground"))

    rm(TEST_CONFIG, name="julia-nightly-dir")
    @test !ispath(joinpath(TEST_CONFIG.bin, "julia-nightly-dir"))
end

test_clean()
test_rm()
