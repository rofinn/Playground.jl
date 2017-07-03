# We could in theory support different types of environments.
# (e.g., DockerEnvironment).
type Environment
    config::Config
    name::AbstractString
    root::AbstractPath
    cache::Dict{AbstractString, Any}  # Used for storing the original environment
    active::Bool
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
    Environment(config, name, envpath(config, dir))
end

function Environment(config::Config, name::String, root::AbstractPath)
    Environment(
        config,
        name,
        root,
        Dict{AbstractString, Any}("ENV" => Dict{AbstractString, Any}()),
        false
    )
end

function init(env::Environment)
    info(logger, "Creating playground environment $(env.name)...")
    for p in (root, bin, log, pkg)
        mkdir(p(env); recursive=true, exist_ok=true)
        debug(logger, "$(p(env)) created.")
    end

    if !isempty(env.name)
        symlink(env.root, abs(join(env.config.share, env.name)), exist_ok=true, overwrite=true)
    end
end

name(env::Environment) = env.name
root(env::Environment) = env.root
isactive(env::Environment) = env.active
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

function defaultprompt(env::Environment, shell::Bool=true)
    shell ? env.config.shell_prompt : env.config.repl_prompt
end

function getprompt(env::Environment; shell::Bool=true)
    prompt = defaultprompt(env, shell)
    isempty(name(env)) ? prompt : replace(prompt, "playground", name(env))
end

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

function set!(env::Environment, keyvals::Pair...)
    old = Dict{AbstractString, Any}()

    for (key, val) in keyvals
        logenv(key, val)
        old[key] = get(ENV, key, nothing)
        ENV[key] = val
    end

    return old
end

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

function logenv(key, val)
    if key == "PATH"
        paths = join(unique(split(val, ":")), "\n\t")
        debug(logger, "Set $key = \n\t$paths")
    else
        debug(logger, "Set $key = $val")
    end
end

function Base.withenv(f::Function, env::Environment)
    env.active = true
    old = set!(env, getenvs(env)...)
    try
        f()
    finally
        restore!(old)
        env.active = false
    end
end
