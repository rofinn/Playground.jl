import YAML: load

"""
    Config(p"~/.playground/config.yml", root=p"~/.playground")

Stores various default playground environment settings including paths for
storing shared binaries and environments.
"""
type Config
    root::AbstractPath
    tmp::AbstractPath
    src::AbstractPath
    bin::AbstractPath
    share::AbstractPath
    default_playground_path::AbstractPath
    default_shell::AbstractString
    default_registry::AbstractString
    default_branch::AbstractString
    default_git_address::AbstractString
    default_git_revision::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Config(kwargs::Dict)
        root = kwargs["root"]
        default_pg_path = abs(Path(kwargs["default_playground_path"]))

        new(
            root,
            join(root, p"tmp"),
            join(root, p"src"),
            join(root, p"bin"),
            join(root, p"share"),
            default_pg_path,
            get(kwargs, "default_shell", ""),
            get(kwargs, "default_registry", ""),
            get(kwargs, "default_branch", ""),
            kwargs["default_git_address"],
            kwargs["default_git_revision"],
            kwargs["isolated_shell_history"],
            kwargs["isolated_julia_history"],
        )
    end
end

function Config(config::AbstractString, root::AbstractPath)
    config_dict = load(config)
    config_dict["root"] = root
    return Config(config_dict)
end

function Config{P<:AbstractPath}(file::P, root::P=configpath())
    Config(read(file), root)
end

function Config()
    config_file = join(configpath(), "config.yml")
    if exists(config_file)
        return Config(config_file)
    else
        return Config(Playground.DEFAULT_CONFIG, configpath())
    end
end

function init(config::Config)
    for p in (config.root, config.tmp, config.src, config.bin, config.share)
        mkdir(p; recursive=true, exist_ok=true)
    end
end

function configpath()
    default_path = join(home(), ".playground")
    alt_path = join(parent(parent(Path(@__FILE__))), p"deps", p"usr", p".playground")
    exists(default_path) ? default_path : alt_path
end

function envpath(config::Config)
    p = abs(join(cwd(), config.default_playground_path))
    debug(logger, "Using `default_playground_path`: $p")
    return p
end

envpath(config::Config, name::AbstractString) = abs(join(config.share, name))
envpath(config::Config, path::AbstractPath) = abs(path)

function envname(config::Config, path::AbstractPath)
    root_path = abs(path)
    name = ""

    for p in readdir(config.share)
        file_path = join(config.share, p)
        if islink(file_path)
            if abs(readlink(file_path)) == root_path
                name = basename(p)
                break
            end
        end
    end

    return name
end
