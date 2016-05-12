# currently only creates a symlink
function mklink(src::AbstractString, dest::AbstractString; soft=true, overwrite=true)
    if ispath(src)
        if ispath(dest) && soft && overwrite
            rm(dest, recursive=true)
        end

        if !ispath(dest)
            @unix_only begin
                run(`ln -s $(src) $(dest)`)
            end
            @windows_only begin
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


function julia_url(version::VersionNumber, os::Symbol=OS_NAME, arch::Integer=WORD_SIZE)
    # Cannibalized from https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/julia.rb

    if os === :Linux && arch == 64
        os_arch = "linux/x64"
        ext = "linux-x86_64.tar.gz"
        # nightly_ext = "linux64.tar.gz"
    elseif os === :Linux && arch == 32
        os_arch = "linux/x32"
        ext = "linux-i686.tar.gz"
        # nightly_ext = "linux32.tar.gz"
    elseif os === :Darwin && arch == 64
        os_arch = "osx/x64"
        ext = "osx10.7+.dmg"
        # nightly_ext = "osx.dmg"
    elseif os === :Windows && arch == 64
        os_arch = "winnt/x64"
        ext = "win64.exe"
    elseif os === :Windows && arch == 32
        os_arch = "winnt/x86"
        ext = "win32.exe"
    else
        error("Julia does not support $arch-bit $os")
    end

    major_minor = "$(version.major).$(version.minor)"
    if version.patch == 0
        url = "s3.amazonaws.com/julialang/bin/$os_arch/$major_minor/julia-$major_minor-latest-$ext"
    else
        url = "s3.amazonaws.com/julialang/bin/$os_arch/$major_minor/julia-$version-$ext"
    end

    # Nightly url:
    # url = "s3.amazonaws.com/julianightlies/bin/$os_arch/julia-latest-$nightly_ext"

    return "https://$url"
end
