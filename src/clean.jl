function clean_links(config::Config)
    for p in readdir(config.dir.store)
        file_path = abspath(joinpath(config.dir.store, p))
        if islink(file_path)
            try
                readlink(file_path)
            catch
                rm(file_path)
            end
        end
    end
end


function clean_rm(config::Config; name::AbstractString="", dir::AbstractString="")
    julia-version = ""

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
    rm(abspath(dir), recursive=true)

    # Just to be safe run clean_links
    clean_links(config)
    return true
end
