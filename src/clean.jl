function clean(config::Config)
    function rm_deadlinks(dir)
        for f in readdir(dir)
            file_path = abs(join(dir, f))
            src = file_path

            while islink(src)
                src = join(parent(src), readlink(src))
            end

            src = abs(src)
            if !exists(src)
                debug(logger, "Removing $file_path")
                remove(file_path)
            end
        end
    end
    rm_deadlinks(config.share)
    rm_deadlinks(config.bin)
end


function Base.rm(config::Config; name::AbstractString="", dir::AbstractPath=Path())
    if !isempty(name) && isempty(dir)
        # If we find the name in the bin folder then we should just delete the julia symlink
        if name in readdir(abs(config.bin)) && name != "playground"
            path = join(abs(config.bin), name)
            debug(logger, "Removing $path")
            remove(path)
            return true
        # Otherwise the name should be in
        elseif name in readdir(abs(config.share))
            dir = get_playground_dir(config, "", name)

            # The dir returned could be a link
            # so we attempt to read that link.
            if islink(dir)
                try
                    dir = readlink(dir)
                catch
                    # If it fails just assume that we have a dead link
                    # and run clean_link and return
                    debug(logger, "Removing $dir")
                    remove(dir)
                    return true
                end
            end
        else
            error("Unknown name $name")
        end
    elseif isempty(dir) && isempty(name)
        error(logger, "No julia-version, playground name or directory provided.")
    end

    # By this point dir should be valid or the function should have already exited.
    # DeclarativePackages creates a read-only directory so in case we run into that
    # during deletion we recursively chmod the path with write permissions.
    # run(`chmod -R +w $(abspath(dir))`)
    chmod(abs(dir), "+w"; recursive=true)
    warn(logger, "Recusively deleting $(abs(dir))...")
    remove(abs(dir); recursive=true)

    # Just to be safe run clean_links
    clean(config)
    return true
end
