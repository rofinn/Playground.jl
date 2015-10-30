# @doc doc"""
#     Lets us use wget to check that all the binurls are still valid.
# """ ->
function check_url(url::AbstractString)
    try
        run(`wget -q --spider $url`)
    catch exc
        error("$url not reachable.")
    end
end

function test_url_parsing()
    os_name = OS_NAME
    for v in [v"0.4", v"0.5"]
        for platform in [:Darwin, :Linux, :Windows]
            OS_NAME = platform
            try
                Playground.get_julia_dl_url(v, TEST_CONFIG)
            catch e
                error("Failed to parse julia download url for $v on $OS_NAME")
            end
        end
    end
end

function test_install()
    install(TEST_CONFIG, v"0.4.0"; labels=["julia-bin", "julia-stable-bin"])
    install(TEST_CONFIG, v"0.5.0"; labels=["julia-nightly-bin"])
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

test_url_parsing()
test_install()
test_dirinstall()
