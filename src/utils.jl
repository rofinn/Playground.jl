# A set of utility function that might be able
# to get merged into base julia.
if VERSION < v"0.4-"
    const VERSION_REGEX = r"^
        v?                                      # prefix        (optional)
        (\d+)                                   # major         (required)
        (?:\.(\d+))?                            # minor         (optional)
        (?:\.(\d+))?                            # patch         (optional)
        (?:(-)|                                 # pre-release   (optional)
        ([a-z][0-9a-z-]*(?:\.[0-9a-z-]+)*|-(?:[0-9a-z-]+\.)*[0-9a-z-]+)?
        (?:(\+)|
        (?:\+((?:[0-9a-z-]+\.)*[0-9a-z-]+))?    # build         (optional)
        ))
    $"ix

    function Base.mktempdir(parent::ASCIIString)
        randtmp = string(char((rand(10) * 25) + 97 )...)
        dir = joinpath(parent, "tmp$(randtmp)")
        mkpath(dir)
        return dir
    end

    function readlink(link)
        return strip(readall(`readlink -f $link`), '\n')
    end

    function Base.VersionNumber(v::AbstractString)
        m = match(VERSION_REGEX, v)
        m === nothing && throw(ArgumentError("invalid version string: $v"))
        major, minor, patch, minus, prerl, plus, build = m.captures
        major = parse(Int, major)
        minor = minor !== nothing ? parse(Int, minor) : 0
        patch = patch !== nothing ? parse(Int, patch) : 0
        if prerl !== nothing && !isempty(prerl) && prerl[1] == '-'
            prerl = prerl[2:end] # strip leading '-'
        end
        prerl = prerl !== nothing ? split_idents(prerl) : minus == "-" ? ("",) : ()
        build = build !== nothing ? split_idents(build) : plus  == "+" ? ("",) : ()
        return VersionNumber(major, minor, patch, prerl, build)
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
            # Shell out to copy directories cause this isn't supported
            # in v0.3 and I don't feel like copying all of that code into this
            # project.
            if VERSION < v"0.4-" && isdir(src)
                run(`cp $src -R $dest`)
            else
                cp(src, dest)
            end
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
