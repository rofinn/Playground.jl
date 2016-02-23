import Base: withenv

# TODO: Should really be named "Playground". If we do rename this type this file should be
# then named "playground.jl"

type PlaygroundConfig
    root::AbstractString            # absolute path to the playground directory
    name::Nullable{AbstractString}  # global name of the playground

    # Convenience fields
    julia_path::AbstractString      # path to the Julia executable
    pkg_dir::AbstractString         # the playgrounds package directory
    bin_dir::AbstractString

    function PlaygroundConfig(root::Nullable{AbstractString}=nothing, name::Nullable{AbstractString}=nothing)
        # Set the playground root directory if none was given
        if !isnull(root)
            root_dir = get(root)
        else
            if isnull(name)
                root_dir = joinpath(pwd(), CORE.default_playground)
            else
                root_dir = joinpath(CORE.share_dir, get(name))
            end
        end

        # Make root absolute in case directory changes occur
        root_dir = abspath(root_dir)

        new(
            root_dir,
            name,
            joinpath(root_dir, "bin", "julia"),
            joinpath(root_dir, "packages"),
            joinpath(root_dir, "bin"),
        )
    end
end

function PlaygroundConfig(root::Union{AbstractString,Void}, name::Union{AbstractString,Void}=nothing)
    # TODO: Temporary
    if root !== nothing && isempty(root)
        root = nothing
    end
    if name !== nothing && isempty(name)
        name = nothing
    end

    PlaygroundConfig(Nullable{AbstractString}(root), Nullable{AbstractString}(name))
end

function exists(pg::PlaygroundConfig)
    isdir(pg.root) && ispath(pg.julia_path) && isdir(pg.pkg_dir) && isdir(pg.bin_dir)
end

function load_playground_from_dir(dir::AbstractString)
    playground = PlaygroundConfig(dir, playground_name(dir))
    !exists(playground) && error("Playground does not exist")
    return playground
end

function load_playground_from_name(name::AbstractString)
    dir = playground_dir(name)
    dir == nothing && error("Playground with global name \"$name\" does not exist. Maybe you meant \"./$name\"?")

    playground = PlaygroundConfig(dir, name)
    !exists(playground) && error("Playground does not exist")
    return playground
end

function load_playground(dir::AbstractString, name::AbstractString)
    if !isempty(dir) && !isempty(name)
        error("only dir or name is expected but not both")
    elseif !isempty(dir)
        load_playground_from_dir(dir)
    elseif !isempty(name)
        load_playground_from_name(name)
    else
        error("dir or name is expected")
    end
end

function remove(pg::PlaygroundConfig)
    # Remove non-link directory
    root = abspath(realpath(pg.root))
    run(`chmod -R +w $root`)
    warn("Deleting playground $root")
    rm(root, recursive=true)

    # Remove global name symlink
    if !isnull(pg.name)
        name = get(pg.name)
        global_root = joinpath(CORE.share_dir, name)

        if islink(global_root)
            warn("Deleting playground reference: $name")
            rm(global_root)
        end
    end
end

"""
    playground_name(dir) -> Union{AbstractString,Void}

Determine the playground's global name from the directory. Returns `nothing` if directory
is not a playground or does not have a global name.
"""
function playground_name(dir::AbstractString)
    expected_root = abspath(normpath(dir))
    for name in readdir(CORE.share_dir)
        root = abspath(realpath(joinpath(CORE.share_dir, name)))

        if root == expected_root
            return name
        end
    end

    return nothing
end

"""
    playground_dir(name) -> Union{AbstractString,Void}

Determine the playground root directory from the global name. Returns `nothing` if the name
doesn't exist.
"""
function playground_dir(name::AbstractString)
    root = joinpath(CORE.share_dir, name)
    return ispath(root) ? realpath(root) : nothing
end


function prompt(pg::PlaygroundConfig)
    prompt_str = CORE.default.prompt_template

    if !isnull(pg.name)
        prompt_str = replace(prompt_str, "playground", get(pg.name))
    end

    return prompt_str
end

function shell(pg::PlaygroundConfig)
    # TODO: Function will be much more useful when individual playgrounds have different settings
    !isempty(CORE.default.shell) ? CORE.default.shell : nothing
end

function isolate_julia_history(pg::PlaygroundConfig)
    # TODO: Function will be much more useful when individual playgrounds have different settings
    CORE.default.isolate_julia_history
end

function isolate_shell_history(pg::PlaygroundConfig)
    # TODO: Function will be much more useful when individual playgrounds have different settings
    CORE.default.isolate_shell_history
end


function withenv(body::Function, pg::PlaygroundConfig)
    env = Dict{AbstractString,AbstractString}()
    env["PATH"] = "$(pg.bin_dir):$(ENV["PATH"])"

    # TODO: the playground root directory would probably be more useful
    env["PLAYGROUND_ENV"] = get(pg.name, basename(pg.root))
    env["JULIA_PKGDIR"] = pg.pkg_dir

    shell_env = shell(pg)
    if shell_env != nothing
        env["SHELL"] = shell_env
    end

    if isolate_julia_history(pg)
        env["JULIA_HISTORY"] = joinpath(pg.root, ".julia_history")
    end

    if isolate_shell_history(pg)
        env["HISTFILE"] = joinpath(pg.root, ".shell_history")
    end

    withenv(body, env...)
end
