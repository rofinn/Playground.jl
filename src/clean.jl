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
    debug(logger, "Cleaning $(config.share)...")
    rm_deadlinks(config.share)
    debug(logger, "Cleaning $(config.bin)...")
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
            dir = envpath(config, name)

            # The dir returned could be a link
            # so we attempt to read that link.
            if islink(dir)
                dir = readlink(dir)

                if !exists(dir)
                    # If the linked path doesn't exist then simply run clean
                    # and return true.
                    clean(config)
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
    warn(logger, "Recusively deleting $(abs(dir))...")
    chmod(abs(dir), "+w"; recursive=true)
    remove(abs(dir); recursive=true)

    # Just to be safe run clean_links
    clean(config)
    return true
end
