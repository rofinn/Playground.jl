@doc doc"""
    The simplest install involves providing the just
    the version number only counting the latest minor version.

    This method will just try and download the latest
    binary version for your platform, or downloads and builds
    it from source if `src` is true.
""" ->
function install{S<:AbstractString}(config::Config, version::VersionNumber; labels::Array{S}=[])
    init(config)

    # download the julia version
    download_url = julia_url(version)
    base_name = "julia-$(version.major).$(version.minor)_$(Dates.today())"
    tmp_dest = joinpath(config.dir.tmp, base_name)

    info("Downloading julia $(version.major).$(version.minor) from $download_url ...")
    Playground.download(download_url, tmp_dest, false)

    # Perform some verification on the download
    if stat(tmp_dest).size < 1024
        # S3 responds with an error message when a URL doesn't exist
        unavailable = open(tmp_dest, "r") do f
            contains(readall(f), "key does not exist")
        end

        if unavailable
            error("Julia version $version does not exist")
        else
            error("Aborting install. Download appears corrupt")
        end
    end

    # Install pre-compiled Julia
    julia_exec = install_julia(tmp_dest, joinpath(config.dir.src, base_name))

    # Make sure that the permissions for the julia executable is set correctly
    chmod(julia_exec, 0o755)

    # Generate a link to make this Julia revision globally accessible
    primary_alias = joinpath(config.dir.bin, base_name)
    println("Linking $julia_exec -> $primary_alias")
    mklink(julia_exec, primary_alias)

    Playground.link_julia(primary_alias, config, labels)

    mklink(primary_alias, joinpath(config.dir.bin, "julia-$(version.major).$(version.minor)"))
end


@doc doc"""
    This option simply creates symlinks from an existing julia
    install.
""" ->
function dirinstall{S<:AbstractString}(config::Config, executable::AbstractString; labels::Array{S}=[])
    executable = abspath(executable)

    info("Adding julia labels $labels to $executable")
    if ispath(executable)
        init(config)

        exe = abspath(executable)
        while islink(exe)
            exe = joinpath(dirname(exe), readlink(exe))
        end

        exe = abspath(exe)
        if isexecutable(exe)
            Playground.link_julia(exe, config, labels)
        else
            error("$exe is not executable.")
        end
    else
        error("$executable is not a valid path")
    end
end


# @doc doc"""
#    This option
#         1. clones the git repo from the provided url.
#         2. checks out the supplied revision into the local branch_name.
#         3. attempts to build julia from scratch.
# """ ->
# function gitinstall(config::Config; url::ASCIIString="", dir::AbstractString="", revision="", labels=[])

#     error("Installing from a git repo isn't implemented yet.")

#     info("Cloning the julia repository into the playground")
#     run(`git clone $(url) $(name)` |> gitlog)

#     # Handle the cd into and out of src directory cause cd() in base
#     # seems to be broken.
#     cwd = pwd()
#     cd(dest)
#     build_julia(julia, , log_path)
#     cd(cwd)
# end


function link_julia{S<:AbstractString}(bin_path::AbstractString, config::Config, labels::Array{S}=[])
    for label in labels
        mklink(bin_path, joinpath(config.dir.bin, label))
    end

    @unix_only begin
        ret = readall(`$(bin_path) -e versioninfo()`)
        lines = split(ret, "\n")

        versionstr = split(lines[1], " ")[3]
        mklink(bin_path, joinpath(config.dir.bin, "julia-$(versionstr)"))

        commit_sha = strip(split(lines[2], " ")[2], '*')
        mklink(bin_path, joinpath(config.dir.bin, "julia-$(commit_sha)"))
    end
end


# function build_julia(target, root_path, log_path)
#     info("Building julia ( $(target) )...")
#     gitlog = joinpath(log_path, "git.log")
#     buildlog = joinpath(log_path, "build.log")

#     run(`git checkout $(target)` >> gitlog)
#     info("checking out $(target)")

#     # Write the different prefix to the Make.user file before
#     # building and installing.
#     info("setting prefix in Make.user")
#     fstrm = open("Make.user","w")
#     write(fstrm, "prefix=$(root_path)")

#     info("Building julia")
#     # Build and install.
#     # TODO: log the build output properly in root_dir/log
#     run(`make` |> buildlog)
#     run(`make install` >> buildlog)
#     println("Julia has been built and installed.")
# end

@osx_only function install_julia(installer::AbstractString, dest::AbstractString)
    mount_dir = mktempdir()
    try
        # Installer is a disk image
        run(`hdiutil attach -mountpoint $mount_dir $installer`)

        app_name = first(filter(f -> endswith(f, ".app"), readdir(mount_dir)))
        app_path = joinpath(mount_dir, app_name)

        copy(app_path, dest)
        julia_exec = joinpath(dest, "Contents", "Resources", "julia", "bin", "julia")

        return julia_exec
    finally
        run(`hdiutil detach $mount_dir`)
        rm(mount_dir)
    end
end

@linux_only function install_julia(installer::AbstractString, dest::AbstractString)
    mkpath(dest)
    try
        run(`tar -xzf $installer -C $dest`)
    catch
        rm(dest, recursive=true)
    end

    julia_exec = joinpath(dest, first(readdir(dest)), "bin", "julia")
    return julia_exec
end

@windows_only function install_julia(installer::AbstractString, dest::AbstractString)
    # not sure what to do here yet.
    error("installing Julia EXEs on Windows not implemented yet.")
end
