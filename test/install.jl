
@doc doc"""
    Lets us use wget to check that all the binurls are still valid.
""" ->
function check_url(url::AbstractString)
    try
        run(`wget -q --spider $url`)
    catch exc
        error("$url not reachable.")
    end
end

function test_urls()
    for key in keys(binurls)
        check_url(binurls[key])
    end
end

function test_install()
    install(TEST_CONFIG, v"0.3.11"; labels=["julia-bin", "julia-stable-bin"])
    install(TEST_CONFIG, v"0.4.0"; labels=["julia-nightly-bin"])
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

test_urls()
test_install()
test_dirinstall()
