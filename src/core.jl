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

config_path() = joinpath(homedir(), ".playground")
