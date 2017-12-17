"""
    Environment([config::Config], [name::String], [root::AbstractPath])

An environment stores information about a playground environment and
provides methods fro interacting with them.

NOTE: In the future we might want to support different types of environments
(e.g., DockerEnvironment).
"""
type Environment
    config::Config
    name::AbstractString
    root::AbstractPath
end

Environment() = Environment(Config())

function Environment(config::Config)
    root = envpath(config)
    name = envname(config, root)
    Environment(config, name, root)
end

Environment(name::String) = Environment(Config(), name)
Environment(dir::AbstractPath) = Environment(Config(), dir)
Environment(config::Config, name::String) = Environment(config, name, envpath(config, name))

function Environment(config::Config, dir::AbstractPath)
    root = envpath(config, dir)
    name = envname(config, root)
    Environment(config, name, root)
end

function Environment(config::Config, dir::AbstractPath, name::String)
    p = if isempty(dir) && isempty(name)
        envpath(config)
    elseif isempty(dir) && !isempty(name)
        envpath(config, name)
    else
        envpath(config, dir)
    end

    debug(logger, "Environment: Name=$name, Path=$p")
    return Environment(config, name, p)
end

function init(env::Environment)
    for f in (root, bin, log, pkg)
        p = f(env)

        if !exists(p)
            mkdir(p; recursive=true)
            debug(logger, "$p created.")
        end
    end

    # If the playground name is set and the root path isn't already in the
    # shared folder then create a symlink.
    share_path = abs(join(env.config.share, env.name))
    if !isempty(env.name) && env.root != share_path
        symlink(env.root, share_path, exist_ok=true, overwrite=true)
    end
end

name(env::Environment) = env.name
root(env::Environment) = env.root
log(env::Environment) = join(env.root, p"log")
bin(env::Environment) = join(env.root, p"bin")
pkg(env::Environment) = join(env.root, p"packages")
julia(env::Environment) = join(env.root, p"bin", p"julia")
shell(env::Environment) = env.config.default_shell
function history(env::Environment, lang::Symbol)
    if lang === :shell
        env.config.isolated_shell_history
    elseif lang === :julia
        env.config.isolated_julia_history
    else
        error(logger, "Unsupported history language $lang")
    end
end

"""
    getenvs(env::Environmnet) -> Vector{Pair}

Generates a set of environment variable changes to make from the
`Environment`.
"""
function getenvs(env::Environment)
    envs = Pair[]
    path = "$(bin(env)):" * ENV["PATH"]
    envname = name(env) == "" ? basename(root(env)) : name(env)
    push!(envs, "PATH" => path, "PLAYGROUND_ENV" => envname, "JULIA_PKGDIR" => pkg(env))

    if !isempty(shell(env))
        push!(envs, "SHELL" => shell(env))
    end

    if history(env, :julia)
        jh = join(root(env), p".julia_history")
        push!(envs, "JULIA_HISTORY" => jh)
    end

    if history(env, :shell)
        sh = join(root(env), p".shell_history")
        push!(envs, "HISTFILE" => sh)
    end

    return envs
end

"""
    set!(env::Environment, keyvals::Pair...) -> Dict

Applies a the `keyvals` to `ENV` and returns the old
`ENV` settings to be used for restore the `ENV` state.
"""
function set!(env::Environment, keyvals::Pair...)
    old = Dict{AbstractString, Any}()

    for (key, val) in keyvals
        logenv(key, val)
        old[key] = get(ENV, key, nothing)
        ENV[key] = val
    end

    return old
end

"""
    restore!(old::Dict{AbstractString, Any})

Applies the `old` dict to `ENV` to restore the environment state.
"""
function restore!(old::Dict{AbstractString, Any})
    for (key, val) in old
        if val !== nothing
            logenv(key, val)
            ENV[key] = val
        else
            debug(logger, "Deleted $key")
            delete!(ENV, key)
        end
    end
end

"""
    logenv(key, val)

Internal utility method used for nicely logging environment variable
changes.
"""
function logenv(key, val)
    if key == "PATH"
        paths = join(unique(split(val, ":")), "\n\t")
        debug(logger, "Set $key = \n\t$paths")
    else
        debug(logger, "Set $key = $val")
    end
end

"""
    withenv(f::Function, env::Environment)

Works the same as `withenv(f, keyvals...)`, but is specific to running `f` within
a playground `Environment`.
"""
function Base.withenv(f::Function, env::Environment)
    old = set!(env, getenvs(env)...)
    try
        f()
    finally
        restore!(old)
    end
end
