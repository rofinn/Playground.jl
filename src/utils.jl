function julia_url(version)
    os = @compat @static VERSION >= v"0.5.0" ? Base.Sys.KERNEL : Base.OS_NAME
    arch = @compat @static VERSION >= v"0.5.0" ? Base.Sys.WORD_SIZE : Base.WORD_SIZE
    julia_url(version, os, arch)
end

function julia_url(version::VersionNumber, os::Symbol, arch::Integer)
    # Cannibalized from https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/julia.rb
    if os === :Linux && arch == 64
        os_arch = "linux/x64"
        ext = "linux-x86_64.tar.gz"
        nightly_ext = "linux64.tar.gz"
    elseif os === :Linux && arch == 32
        os_arch = "linux/x32"
        ext = "linux-i686.tar.gz"
        nightly_ext = "linux32.tar.gz"
    elseif os === :Darwin && arch == 64
        os_arch = "mac/x64"
        ext = "mac64.dmg"
        nightly_ext = ext
    elseif os === :Windows && arch == 64
        os_arch = "winnt/x64"
        ext = "win64.exe"
        nightly_ext = ext
    elseif os === :Windows && arch == 32
        os_arch = "winnt/x86"
        ext = "win32.exe"
        nightly_ext = ext
    else
        error(logger, "Julia does not support $arch-bit $os")
    end

    # Note: We could probably get specific revisions if we really wanted to.
    # eg. https://status.julialang.org/download/osx10.7+ redirects to
    # https://s3.amazonaws.com/julianightlies/bin/osx/x64/0.5/julia-0.5.0-2bb94d6f99-osx.dmg

    major_minor = "$(version.major).$(version.minor)"
    future_release = Base.nextpatch(NIGHTLY)  # Note: Nightly expected to be a prerelease
    pre = version.prerelease
    if version >= future_release
        throw(ArgumentError("The version $version exceeds the latest known nightly build $NIGHTLY"))
    elseif version >= NIGHTLY
        # https://status.julialang.org/download/linux-x86_64
        url = "s3.amazonaws.com/julianightlies/bin/$os_arch/julia-latest-$nightly_ext"
    elseif version.patch == 0 && (version == Base.upperbound(version) || (length(pre) > 0 && pre[1] == "latest"))
        # https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6-latest-linux-x86_64.tar.gz
        url = "julialang-s3.julialang.org/bin/$os_arch/$major_minor/julia-$major_minor-latest-$ext"
    else
        # https://julialang-s3.julialang.org/bin/linux/x64/0.5/julia-0.5.2-linux-x86_64.tar.gz
        url = "julialang-s3.julialang.org/bin/$os_arch/$major_minor/julia-$version-$ext"
    end

    return "https://$url"
end

function julia_url(version::AbstractString, os::Symbol, arch::Integer)
    if version == "nightly"
        ver = NIGHTLY
    elseif version == "release"
        latest_release = VersionNumber(NIGHTLY.major, NIGHTLY.minor - 1, 0, (), ("",))
        ver = latest_release
    else
        ver = VersionNumber(version)
    end

    return julia_url(ver, os, arch)
end


function log_output(cmd::Cmd)
    try
        stdout = Pipe()
        stderr = Pipe()

        p = spawn(pipeline(cmd, stdin=DevNull, stdout=stdout, stderr=stderr))

        close(stdout.in)
        close(stderr.in)

        # Julia logs print to stderr
        for l in readlines(stderr)
            if startswith(l, "INFO: ")
                debug(logger, join(split(l)[2:end], ' '))
            elseif startswith(l, "WARNING: ")
                warn(logger, join(split(l)[2:end], ' '))
            else
                debug(logger, l)
            end
        end

        for l in readlines(stdout)
            debug(logger, l)
        end
    catch e
        error(logger, e)
    end
end
