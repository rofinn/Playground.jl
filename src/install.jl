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
    tmp_dest = joinpath(config.tmp, base_name)

    info("Downloading julia $(version.major).$(version.minor) from $download_url ...")
    Playground.download(download_url, tmp_dest, false)

    # Perform some verification on the download
    if stat(tmp_dest).size < 1024
        # S3 responds with an error message when a URL doesn't exist
        unavailable = open(tmp_dest, "r") do f
            contains(@compat readstring(f), "key does not exist")
        end

        if unavailable
            error("Julia version $version does not exist")
        else
            error("Aborting install. Download appears corrupt")
        end
    end

    bin_path = Playground.install_julia_bin(tmp_dest, config, base_name, false)
    Playground.link_julia(bin_path, config, labels)

    mklink(bin_path, joinpath(config.bin, "julia-$(version.major).$(version.minor)"))
end


@doc doc"""
    This option simply creates symlinks from an existing julia
    install.
""" ->
function dirinstall{S<:AbstractString}(config::Config, executable::AbstractString; labels::Array{S}=[])
    info("Adding julia labels $labels to $executable")
    if ispath(executable)
        init(config)

        exe = abspath(executable)
        while islink(exe)
            exe = joinpath(dirname(exe), readlink(exe))
        end

        exe = abspath(exe)
        if isfile(exe)
            Playground.link_julia(exe, config, labels)
        else
            error("$exe is not a valid executable.")
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
        mklink(bin_path, joinpath(config.bin, label))
    end

    @compat if is_unix()
        ret = readstring(`$(bin_path) -e versioninfo()`)
        lines = split(ret, "\n")

        versionstr = split(lines[1], " ")[3]
        mklink(bin_path, joinpath(config.bin, "julia-$(versionstr)"))

        commit_sha = strip(split(lines[2], " ")[2], '*')
        mklink(bin_path, joinpath(config.bin, "julia-$(commit_sha)"))
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

@compat if is_apple()
    function install_julia_bin(src::AbstractString, config::Config, base_name, force)
        src_path = abspath(joinpath(config.src, base_name))
        bin_path = abspath(joinpath(config.bin, base_name))
        exe_path = abspath(joinpath(src_path, "Contents/Resources/julia/bin/julia"))

        function install_from_dmg(mountdir::AbstractString)
            app_path = nothing
            try
                run(`hdiutil attach -mountpoint $mountdir $src`)
                for f in readdir(mountdir)
                   if endswith(f, ".app")
                        app_path = joinpath(mountdir, f)
                   end
                end
                if app_path != nothing
                    copy(app_path, src_path)
                    chmod(exe_path, 0o755)
                end
            finally
                run(`hdiutil detach $mountdir`)
            end
        end

        dmg_tmp_dir = mktempdir(config.tmp)
        try
            # Don't bother running this if src_path already exists
            if !ispath(src_path) || force
                install_from_dmg(dmg_tmp_dir)
            end

            mklink(exe_path, bin_path)
        finally
            rm(dmg_tmp_dir)
        end

        return bin_path
    end
elseif is_unix()
    function install_julia_bin(src::AbstractString, config::Config, base_name, force)
        src_path = abspath(joinpath(config.src, base_name))
        bin_path = abspath(joinpath(config.bin, base_name))

        if !ispath(src_path) || force
            mkpath(src_path)
            try
                run(`tar -xzf $src -C $src_path`)
            catch
                rm(src_path, recursive=true)
            end
        end

        julia_bin_path = joinpath(
            src_path,
            readdir(src_path)[1],
            "bin/julia"
        )
        chmod(julia_bin_path, 0o755)
        mklink(julia_bin_path, bin_path)

        return bin_path
    end
elseif is_windows()
    function install_julia_bin(src::AbstractString, config::Config)
        # not sure what to do here yet.
        error("installing Julia EXEs on Windows not implemented yet.")
    end
end
