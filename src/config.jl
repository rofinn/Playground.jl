import YAML: load


type Config
    root::AbstractPath
    tmp::AbstractPath
    src::AbstractPath
    bin::AbstractPath
    share::AbstractPath
    default_playground_path::AbstractPath
    default_prompt::AbstractString
    default_shell::AbstractString
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
            kwargs["default_prompt"],
            haskey(kwargs, "default_shell") ? kwargs["default_shell"] : "",
            kwargs["default_git_address"],
            kwargs["default_git_revision"],
            kwargs["isolated_shell_history"],
            kwargs["isolated_julia_history"],
        )
    end
end

function init(config::Config)
    for p in (config.root, config.tmp, config.src, config.bin, config.share)
        mkdir(p; recursive=true, exist_ok=true)
    end
end

load_config(config::AbstractPath, root::AbstractPath) = load_config(read(config), root)

function load_config(config::AbstractString, root::AbstractPath)
    config_dict = load(config)
    config_dict["root"] = root
    return Config(config_dict)
end


type Environment
    name::AbstractString
    root::AbstractPath
    log::AbstractPath
    bin::AbstractPath
    pkg::AbstractPath
    julia::AbstractPath
    default_shell::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Environment(config::Config, dir::AbstractPath, name::AbstractString)
        root = get_playground_dir(config, dir, name)
        new(
            name,
            root,
            join(root, p"log"),
            join(root, p"bin"),
            join(root, p"packages"),
            join(root, p"bin", p"julia"),
            config.default_shell,
            config.isolated_shell_history,
            config.isolated_julia_history
        )
    end
end

function init(pg::Environment)
    info(logger, "Creating playground environment $(pg.name)...")
    for p in (pg.root, pg.bin, pg.log, pg.pkg)
        mkdir(p; recursive=true, exist_ok=true)
        debug(logger, "$p created.")
    end
end

function set_envs(pg::Environment)
    ENV["PATH"] = "$(pg.bin):" * ENV["PATH"]
    debug(logger, string("PATH=", ENV["PATH"]))

    ENV["PLAYGROUND_ENV"] = pg.name == "" ? basename(pg.root) : pg.name
    debug(logger, string("PLAYGROUND_ENV=", ENV["PLAYGROUND_ENV"]))

    ENV["JULIA_PKGDIR"] = pg.pkg
    debug(logger, "JULIA_PKGDIR=$(pg.pkg)")

    if pg.default_shell != ""
        ENV["SHELL"] = pg.default_shell
        debug(logger, "SHELL=$(pg.default_shell)")
    end

    if pg.isolated_julia_history
        jh = join(pg.root, p".julia_history")
        ENV["JULIA_HISTORY"] = jh
        debug(logger, "JULIA_HISTORY=$jh")
    end

    if pg.isolated_shell_history
        sh = join(pg.root, p".shell_history")
        ENV["HISTFILE"] = sh
        debug(logger, "HISTFILE=$sh")
    end
end

config_path() = join(home(), p".playground")
