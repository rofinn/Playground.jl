function test_install()
    install(TEST_CONFIG, v"0.4.0"; labels=["julia-bin", "julia-old-bin"])
    install(TEST_CONFIG, v"0.5.0"; labels=["julia-bin", "julia-stable-bin"])
    install(TEST_CONFIG, v"0.6.0-latest"; labels=["julia-nightly-bin"])
    install(
        TEST_CONFIG,
        join(TEST_CONFIG.bin, "julia-nightly-bin");
        labels=["julia-nightly-dir"]
    )
    install(
        TEST_CONFIG,
        join(TEST_CONFIG.bin, "julia-stable-bin");
        labels=["julia-stable-dir"]
    )
end

test_install()
