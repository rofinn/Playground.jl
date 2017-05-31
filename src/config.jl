import YAML: load


type Config
    root::AbstractString
    tmp::AbstractString
    src::AbstractString
    bin::AbstractString
    share::AbstractString
    default_playground_path::AbstractString
    default_prompt::AbstractString
    default_shell::AbstractString
    default_git_address::AbstractString
    default_git_revision::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Config(kwargs::Dict)
        root = kwargs["root"]
        new(
            root,
            joinpath(root, "tmp"),
            joinpath(root, "src"),
            joinpath(root, "bin"),
            joinpath(root, "share"),
            abspath(kwargs["default_playground_path"]),
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
        mkpath(p)
    end
end

function load_config(config::AbstractString, root::AbstractString)
    is_path = false

    try
        is_path = ispath(config)
    end

    if is_path
        config_dict = load(open(config))
    else
        config_dict = load(config)
    end

    config_dict["root"] = root

    return Config(config_dict)
end


type Environment
    name::AbstractString
    root::AbstractString
    log::AbstractString
    bin::AbstractString
    pkg::AbstractString
    julia::AbstractString
    default_shell::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Environment(config::Config, dir::AbstractString, name)
        root = get_playground_dir(config, dir, name)
        new(
            name,
            root,
            joinpath(root, "log"),
            joinpath(root, "bin"),
            joinpath(root, "packages"),
            joinpath(root, "bin", "julia"),
            config.default_shell,
            config.isolated_shell_history,
            config.isolated_julia_history
        )
    end
end

function init(pg::Environment)
    for p in (pg.root, pg.bin, pg.log, pg.pkg)
        mkpath(p)
    end
end

function set_envs(pg::Environment)
    ENV["PATH"] = "$(pg.bin):" * ENV["PATH"]
    ENV["PLAYGROUND_ENV"] = pg.name == "" ? basename(pg.root) : pg.name
    ENV["JULIA_PKGDIR"] = pg.pkg

    if pg.default_shell != ""
        ENV["SHELL"] = pg.default_shell
    end

    if pg.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(pg.root, ".julia_history")
    end

    if pg.isolated_shell_history
        ENV["HISTFILE"] = joinpath(pg.root, ".shell_history")
    end
end

config_path() = joinpath(homedir(), ".playground")
