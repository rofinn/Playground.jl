@doc doc"""
    The simplest install involves providing the just
    the version number only counting the latest minor version.

    This method will just try and download the latest
    binary version for your platform, or downloads and builds
    it from source if `src` is true.
""" ->
function install(version::VersionNumber)
    url = julia_url(version)
    info("Downloading Julia $(version.major).$(version.minor) from $url ...")
    installer = download(url)

    # Perform some verification on the download
    if stat(installer).size < 1024
        # S3 responds with an error message when a URL doesn't exist
        unavailable = open(installer, "r") do f
            contains(readall(f), "key does not exist")
        end

        if unavailable
            error("Julia version $version does not exist")
        else
            error("Aborting install. Download appears corrupt")
        end
    end

    # Install Julia to a temporary directory as the final install directory name includes
    # information which we need to run Julia to determine
    tmp_install_dir = joinpath(CORE.tmp_dir, "julia-$(version)_$(Dates.today())")
    julia_exec = install_julia(installer, tmp_install_dir)
    rm(installer)

    # Make sure that the permissions for the julia executable is set correctly
    chmod(julia_exec, 0o755)

    # Retrieve the correct version information from the Julia executable and move the
    # installation to its final directory which should be unique
    vi = VersionInfo(`$julia_exec`)
    installed_dir = joinpath(CORE.src_dir, string(vi))
    mv(tmp_install_dir, installed_dir)
    julia_exec = replace(julia_exec, tmp_install_dir, installed_dir)

    info("Installed Julia version $(vi.version) revision $(vi.revision) built at $(vi.built)")

    # Generate a link to make this Julia revision globally accessible
    primary_alias = joinpath(CORE.bin_dir, "julia-$(string(vi))")
    println("Linking $julia_exec -> $primary_alias")
    mklink(julia_exec, primary_alias)

    return primary_alias, vi
end

@doc doc"""
    This option simply creates symlinks from an existing julia
    install.
""" ->
function link_install(executable::AbstractString)
    # info("Adding julia labels $labels to $executable")
    if ispath(executable)
        julia_exec = abspath(realpath(executable))

        if isexecutable(julia_exec)
            vi = VersionInfo(`$julia_exec`)

            primary_alias = joinpath(CORE.bin_dir, "julia-$(string(vi))")
            println("Linking $julia_exec -> $primary_alias")
            mklink(julia_exec, primary_alias)
        else
            error("$julia_exec is not executable.")
        end
    else
        error("$executable is not a valid path")
    end

    return primary_alias, vi
end

function julia_aliases{S<:AbstractString}(executable::AbstractString, labels::Array{S})
    for label in labels
        mklink(executable, joinpath(CORE.bin_dir, label))
    end
end

function julia_aliases(executable::AbstractString, vi::VersionInfo)
    # Generate additional aliases. Note we are overwritting existing links regardless of
    # whether this latest revision for this version
    v, r = vi.version, vi.revision
    labels = [
        "julia-$(v.major).$(v.minor).$(v.patch)",
        "julia-$(v.major).$(v.minor)",
        "julia-$r",
    ]
    julia_aliases(executable, labels)
end

julia_aliases(exec::AbstractString) = create_aliases(exec, VersionInfo(`$exec`))




# @doc doc"""
#    This option
#         1. clones the git repo from the provided url.
#         2. checks out the supplied revision into the local branch_name.
#         3. attempts to build julia from scratch.
# """ ->
# function gitinstall(config::PlaygroundCore; url::ASCIIString="", dir::AbstractString="", revision="", labels=[])

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
