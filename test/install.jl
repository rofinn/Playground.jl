function test_install()
    install(TEST_CONFIG, v"0.4.0"; labels=["julia-bin", "julia-stable-bin"])
    install(TEST_CONFIG, v"0.5.0-"; labels=["julia-nightly-bin"])
end

function test_dirinstall()
    dirinstall(
        TEST_CONFIG,
        joinpath(TEST_CONFIG.dir.bin, "julia-nightly-bin");
        labels=["julia-nightly-dir"]
    )
    dirinstall(
        TEST_CONFIG,
        joinpath(TEST_CONFIG.dir.bin, "julia-stable-bin");
        labels=["julia-stable-dir"]
    )
end

test_install()
test_dirinstall()
