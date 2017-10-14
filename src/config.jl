import YAML: load

"""
    Config(; file=p"~/.playground/config.yml", root=p"~/.playground")

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
    repl_prompt::AbstractString
    shell_prompt::AbstractString
    default_shell::AbstractString
    default_julia_metadata::AbstractString
    default_julia_meta_branch::AbstractString
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
            kwargs["repl_prompt"],
            kwargs["shell_prompt"],
            get(kwargs, "default_shell", ""),
            get(kwargs, "default_julia_metadata", ""),
            get(kwargs, "default_julia_meta_branch", ""),
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

function Config{P<:AbstractPath}(; file::P=join(configpath(), "config.yml"), root::P=configpath())
    Config(read(file), root)
end

function init(config::Config)
    for p in (config.root, config.tmp, config.src, config.bin, config.share)
        mkdir(p; recursive=true, exist_ok=true)
    end
end

configpath() = join(home(), ".playground")

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
