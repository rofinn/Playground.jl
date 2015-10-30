function clean(config::Config)
    function rm_deadlinks(dir)
        for f in readdir(dir)
            file_path = abspath(joinpath(dir, f))
            src = file_path

            while islink(src)
                src = joinpath(dirname(src), readlink(src))
            end

            src = abspath(src)
            if !ispath(src)
                rm(file_path)
            end
        end
    end
    rm_deadlinks(config.dir.store)
    rm_deadlinks(config.dir.bin)
end


function Base.rm(config::Config; name::AbstractString="", dir::AbstractString="")
    if name != "" && dir == ""
        # If we find the name in the bin folder then we should just delete the julia symlink
        if name in readdir(abspath(config.dir.bin)) && name != "playground"
            rm(joinpath(abspath(config.dir.bin), name))
            return true
        # Otherwise the name should be in
        elseif name in readdir(abspath(config.dir.store))
            dir = get_playground_dir(config, "", name)

            # The dir returned could be a link
            # so we attempt to read that link.
            if islink(dir)
                try
                    dir = readlink(dir)
                catch
                    # If it fails just assume that we have a dead link
                    # and run clean_link and return
                    rm(dir)
                    return true
                end
            end
        else
            error("Unknown name $name")
        end
    elseif dir == "" && name == ""
        error("No juli-version, playground name or directory provided.")
    end

    # By this point dir should be valid or the function should have already exited.
    # DeclarativePackages creates a read-only directory so in case we run into that
    # during deletion we recursively chmod the path with write permissions.
    run(`chmod -R +w $(abspath(dir))`)
    Logging.warn("Recusively deleting $(abspath(dir))...")
    rm(abspath(dir), recursive=true)

    # Just to be safe run clean_links
    clean(config)
    return true
end
