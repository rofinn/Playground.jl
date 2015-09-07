# A set of utility function that might be able
# to get merged into base julia.
if VERSION < v"0.4-"
    function Base.mktempdir(parent::ASCIIString)
        randtmp = string(char((rand(10) * 25) + 97 )...)
        dir = joinpath(parent, "tmp$(randtmp)")
        mkpath(dir)
        return dir
    end

    function readlink(link)
        return strip(readall(`readlink -f $link`), '\n')
    end
end


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


function msg(exc::Exception)
    if isa(exc, ErrorException)
       return exc.msg
    else
       return string(exc)
    end
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
