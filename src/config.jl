import YAML: load


type DirectoryStructure
    root::AbstractString
    tmp::AbstractString
    src::AbstractString
    bin::AbstractString

    function DirectoryStructure(root)
        new(
            root,
            joinpath(root, "tmp"),
            joinpath(root, "src"),
            joinpath(root, "bin"),
        )
    end
end


type Config
    dir::DirectoryStructure
    default_playground_path::AbstractString
    activated_prompt::AbstractString
    default_git_address::AbstractString
    default_git_revision::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function Config(kwargs::Dict)
        new(
            DirectoryStructure(kwargs["root"])
            abspath(kwargs["default_playground_path"])
            kwargs["activated_prompt"]
            kwargs["default_git_address"]
            kwargs["default_git_revision"]
            kwargs["isolated_shell_history"]
            kwargs["isolated_julia_history"]
        )
    end
end

function init(config::Config)
    mkpath(config.dir.tmp)
    mkpath(config.dir.src)
    mkpath(config.dir.bin)
end


function load_config(config::AbstractString; root::AbstractString="$(homedir())/.playground")
    if ispath(path)
        config_dict = load(open(path))
    else
        config_dict = load(path)
    end

    config_dict["root"] = root

    return Config(config_dict)
end
