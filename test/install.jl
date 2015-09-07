test_bin_dir = joinpath(TEST_TMP_DIR, "bin")
mkpath(test_bin_dir)

test_binurls = Dict(
    binurls[v"0.4"] => joinpath(test_bin_dir, basename(binurls[v"0.4"])),
    binurls[v"0.3"] => joinpath(test_bin_dir, basename(binurls[v"0.3"])),
)


@doc doc"""
    We overload download for our tests in order to make sure we're just download. The
    julia builds once.
""" ->
function Base.download(src::ASCIIString, dest::UTF8String)
    if !isfile(test_binurls[src])
        # We cast dest to ASCIIString to make sure we
        # call the general download method
        download(src, ASCIIString(test_binurls[src]))
    end

    if !ispath(dest)
        cp(test_binurls[src], dest)
    end
end

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


for key in keys(binurls)
    check_url(binurls[key])
end

install(v"0.3.11", TEST_CONFIG; labels=["julia-bin", "julia-stable-bin"])
install(v"0.4.0", TEST_CONFIG; labels=["julia-nightly-bin"])

dirinstall(joinpath(TEST_CONFIG.dir.bin, "julia-nightly-bin"), TEST_CONFIG; labels=["julia-nightly-dir"])
dirinstall(joinpath(TEST_CONFIG.dir.bin, "julia-stable-bin"), TEST_CONFIG; labels=["julia-stable-dir"])

