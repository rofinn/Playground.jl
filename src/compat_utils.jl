@doc doc"""
    This file provides some missing methods from julia v0.3. When we deprecate 0.3
    we can just delete this file.
""" ->
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
