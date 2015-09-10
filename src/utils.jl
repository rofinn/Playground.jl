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
function Base.download(src::ASCIIString, dest::AbstractString, overwrite)
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
