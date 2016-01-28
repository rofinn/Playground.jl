import YAML: load


type DirectoryStructure
    root::AbstractString
    tmp::AbstractString
    src::AbstractString
    bin::AbstractString
    store::AbstractString

    function DirectoryStructure(root)
        new(
            root,
            joinpath(root, "tmp"),
            joinpath(root, "src"),
            joinpath(root, "bin"),
            joinpath(root, "share"),
        )
    end
end


type Config
    dir::DirectoryStructure
    default_playground_path::AbstractString
    default_prompt::AbstractString
    default_shell::AbstractString
    default_git_address::AbstractString
    default_git_revision::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Config(kwargs::Dict)
        new(
            DirectoryStructure(kwargs["root"]),
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


type PlaygroundConfig
    name::AbstractString
    root_path::AbstractString
    log_path::AbstractString
    bin_path::AbstractString
    pkg_path::AbstractString
    julia_path::AbstractString
    default_shell::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function PlaygroundConfig(config::Config, dir::AbstractString, name)
        root_path = get_playground_dir(config, dir, name)
        new(
            name,
            root_path,
            joinpath(root_path, "log"),
            joinpath(root_path, "bin"),
            joinpath(root_path, "packages"),
            joinpath(root_path, "bin", "julia"),
            config.default_shell,
            config.isolated_shell_history,
            config.isolated_julia_history
        )
    end
end


function init(config::Config)
    mkpath(config.dir.root)
    mkpath(config.dir.tmp)
    mkpath(config.dir.src)
    mkpath(config.dir.bin)
    mkpath(config.dir.store)
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


function create_paths(pg::PlaygroundConfig)
    mkpath(pg.root_path)
    mkpath(pg.bin_path)
    mkpath(pg.log_path)
    mkpath(pg.pkg_path)
end


function set_envs(pg::PlaygroundConfig)
    ENV["PATH"] = "$(pg.bin_path):" * ENV["PATH"]
    ENV["PLAYGROUND_ENV"] = pg.name == "" ? basename(pg.root_path) : pg.name
    ENV["JULIA_PKGDIR"] = pg.pkg_path

    if pg.default_shell != ""
        ENV["SHELL"] = pg.default_shell
    end

    if pg.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(pg.root_path, ".julia_history")
    end

    if pg.isolated_shell_history
        ENV["HISTFILE"] = joinpath(pg.root_path, ".shell_history")
    end
end

config_path() = joinpath(homedir(), ".playground")
