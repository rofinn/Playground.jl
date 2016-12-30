# currently only creates a symlink
function mklink(src::AbstractString, dest::AbstractString; soft=true, overwrite=true)
    if ispath(src)
        if ispath(dest) && soft && overwrite
            rm(dest, recursive=true)
        end

        if !ispath(dest)
            @compat if is_unix()
                run(`ln -s $(src) $(dest)`)
            elseif is_windows()
                if isfile(src)
                    run(`mklink $(dest) $(src)`)
                else
                    run(`mklink /D $(dest) $(src)`)
                end
            end
        elseif !soft
            error("$(dest) already exists.")
        end
    else
        error("$(src) is not a valid path")
    end
end


function copy(src::AbstractString, dest::AbstractString; soft=true, overwrite=true)
    if ispath(src)
        if ispath(dest) && soft && overwrite
            rm(dest, recursive=true)
        end

        if !ispath(dest)
            # Shell out to copy directories cause this isn't supported
            # in v0.3 and I don't feel like copying all of that code into this
            # project. This if should be deleted when 0.3 is deprecated
            cp(src, dest)
        elseif !soft
            error("$(dest) already exists.")
        end
    else
        error("$(src) is not a valid path")
    end
end


@doc doc"""
    We overload download for our tests in order to make sure we're just download. The
    julia builds once.
""" ->
function Base.download(src::AbstractString, dest::AbstractString, overwrite)
    if !ispath(dest) || overwrite
        download(src, dest)
    end
    return dest
end


function get_playground_dir(config::Config, dir::AbstractString, name::AbstractString)
    if dir == "" && name == ""
        return abspath(joinpath(pwd(), config.default_playground_path))
    elseif dir == "" && name != ""
        return abspath(joinpath(config.dir.store, name))
    elseif dir != ""
        return abspath(dir)
    end
end


function get_playground_name(config::Config, dir::AbstractString)
    root_path = abspath(dir)
    name = ""

    for p in readdir(config.dir.store)
        file_path = joinpath(config.dir.store, p)
        if islink(file_path)
            if abspath(readlink(file_path)) == root_path
                name = p
                break
            end
        end
    end

    return name
end

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
        os_arch = "osx/x64"
        ext = "osx10.7+.dmg"
        nightly_ext = "osx.dmg"
    elseif os === :Windows && arch == 64
        os_arch = "winnt/x64"
        ext = "win64.exe"
        nightly_ext = ext
    elseif os === :Windows && arch == 32
        os_arch = "winnt/x86"
        ext = "win32.exe"
        nightly_ext = ext
    else
        error("Julia does not support $arch-bit $os")
    end

    # Note: We could probably get specific revisions if we really wanted to.
    # eg. https://status.julialang.org/download/osx10.7+ redirects to
    # https://s3.amazonaws.com/julianightlies/bin/osx/x64/0.5/julia-0.5.0-2bb94d6f99-osx.dmg

    major_minor = "$(version.major).$(version.minor)"
    future_release = Base.nextpatch(NIGHTLY)  # Note: Nightly expected to be a prerelease
    if version >= future_release
        throw(ArgumentError("The version $version exceeds the latest known nightly build $NIGHTLY"))
    elseif version >= NIGHTLY
        url = "s3.amazonaws.com/julianightlies/bin/$os_arch/julia-latest-$nightly_ext"
    elseif version.patch == 0 && version == Base.upperbound(version)
        url = "s3.amazonaws.com/julialang/bin/$os_arch/$major_minor/julia-$major_minor-latest-$ext"
    else
        url = "s3.amazonaws.com/julialang/bin/$os_arch/$major_minor/julia-$version-$ext"
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
