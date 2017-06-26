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
    tmp_dest = join(config.tmp, base_name)

    info(logger, "Downloading julia $(version.major).$(version.minor) from $download_url ...")
    download(download_url, tmp_dest, false)

    # Perform some verification on the download
    if stat(tmp_dest).size < 1024
        # S3 responds with an error message when a URL doesn't exist
        unavailable = open(tmp_dest, "r") do f
            contains((@compat readstring(f)), "key does not exist")
        end

        if unavailable
            error(logger, "Julia version $version does not exist")
        else
            error(logger, "Aborting install. Download appears corrupt")
        end
    end

    bin_path = Playground.install_bin(tmp_dest, config, base_name, false)
    Playground.link_julia(bin_path, config, labels)

    label_path = join(config.bin, "julia-$(version.major).$(version.minor)")
    debug(logger, "Creating link $label_path -> $bin_path")
    symlink(bin_path, label_path; exist_ok=true, overwrite=true)
end


@doc doc"""
    This option simply creates symlinks from an existing julia
    install.
""" ->
function install{S<:AbstractString}(config::Config, executable::AbstractPath; labels::Array{S}=[])
    info(logger, "Adding julia labels $labels to $executable")
    if exists(executable)
        init(config)

        exe = abs(executable)
        while islink(exe)
            exe = join(parent(exe), readlink(exe))
        end

        exe = abs(exe)
        if isfile(exe)
            Playground.link_julia(exe, config, labels)
        else
            error(logger, "$exe is not a valid executable.")
        end
    else
        error(logger, "$executable is not a valid path")
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


function link_julia{S<:AbstractString}(bin_path::AbstractPath, config::Config, labels::Array{S}=[])
    bin_path = abs(bin_path)
    for label in labels
        label_path = join(config.bin, label)
        debug(logger, "Creating link $label_path -> $bin_path")
        symlink(bin_path, label_path; exist_ok=true, overwrite=true)
    end

    @compat if is_unix()
        ret = readstring(`$(bin_path) -e 'versioninfo()'`)
        lines = split(ret, "\n")

        versionstr = split(lines[1], " ")[3]
        debug(logger, "Creating link julia-$(versionstr) -> $bin_path")
        symlink(bin_path, join(config.bin, "julia-$(versionstr)"); exist_ok=true, overwrite=true)

        commit_sha = strip(split(lines[2], " ")[2], '*')
        debug(logger, "Creating link julia-$(commit_sha) -> $bin_path")
        symlink(bin_path, join(config.bin, "julia-$(commit_sha)"); exist_ok=true, overwrite=true)
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
    function install_bin(src::AbstractPath, config::Config, base_name, force)
        src_path = abs(join(config.src, base_name))
        bin_path = abs(join(config.bin, base_name))
        exe_path = abs(join(src_path, "Contents/Resources/julia/bin/julia"))

        function install_dmg(mountdir::AbstractPath)
            app_path = nothing
            try
                debug(logger, "Mounting $src @ $mountdir")
                run(`hdiutil attach -mountpoint $mountdir $src`)
                for f in readdir(mountdir)
                   if extension(f) == "app"
                        app_path = join(mountdir, f)
                        break
                   end
                end
                if app_path != nothing
                    debug(logger, "Copying $app_path to $src_path")
                    copy(app_path, src_path)
                    chmod(exe_path, Playground.JULIA_BIN_MODE)
                    debug(logger, "Permissions set to $(Playground.JULIA_BIN_MODE)")
                end
            finally
                debug("Detaching $src from $mountdir")
                run(`hdiutil detach $mountdir`)
            end
        end

        dmg_tmp_dir = mktmpdir(config.tmp)
        try
            # Don't bother running this if src_path already exists
            if !exists(src_path) || force
                info(logger, "Installing $src ...")
                install_dmg(dmg_tmp_dir)
            end

            debug(logger, "Creating link $bin_path -> $exe_path")
            symlink(exe_path, bin_path; exist_ok=true, overwrite=true)
        finally
            remove(dmg_tmp_dir)
        end

        return bin_path
    end
elseif is_unix()
    function install_bin(src::AbstractPath, config::Config, base_name, force)
        src_path = abs(join(config.src, base_name))
        bin_path = abs(join(config.bin, base_name))

        info(logger, "Installing $src ...")
        if !ispath(src_path) || force
            mkpath(src_path)
            try
                debug(logger, "Extracting $src to $src_path")
                run(`tar -xzf $src -C $src_path`)
            catch
                remove(src_path, recursive=true)
            end
        end

        julia_bin_path = join(src_path, readdir(src_path)[1], p"bin/julia")
        chmod(julia_bin_path, Playground.JULIA_BIN_MODE)
        debug(logger, "Permissions set to $(Playground.JULIA_BIN_MODE)")
        debug(logger, "Creating link $bin_path -> $julia_bin_path")
        symlink(julia_bin_path, bin_path; exist_ok=true, overwrite=true)

        return bin_path
    end
elseif is_windows()
    function install_bin(src::AbstractPath, config::Config)
        # not sure what to do here yet.
        error(logger, "installing Julia EXEs on Windows not implemented yet.")
    end
end
