import YAML

type PlaygroundSettings
    prompt_template::AbstractString
    shell::AbstractString
    isolate_shell_history::Bool
    isolate_julia_history::Bool
end

# Contains information pertaining to the playground home directory
type PlaygroundCore
    root_dir::AbstractString
    tmp_dir::AbstractString
    src_dir::AbstractString
    bin_dir::AbstractString
    share_dir::AbstractString  # directory containing dirs/links to globally accessible playgrounds

    # Settings specific to the global playground home
    default_playground::AbstractString
    default_git_address::AbstractString
    default_git_revision::AbstractString

    # Default settings for individual playgrounds
    default::PlaygroundSettings
end

function PlaygroundCore(
    root::AbstractString=PLAYGROUND_HOME;
    default_playground::AbstractString=DEFAULT_PLAYGROUND,
    default_git_address::AbstractString=DEFAULT_GIT_ADDRESS,
    default_git_revision::AbstractString=DEFAULT_GIT_REVISION,
    default_prompt_template::AbstractString=DEFAULT_PROMPT_TEMPLATE,
    default_shell::AbstractString=DEFAULT_SHELL,
    default_isolate_shell_history::Bool=DEFAULT_ISOLATE_SHELL_HISTORY,
    default_isolate_julia_history::Bool=DEFAULT_ISOLATE_JULIA_HISTORY,
)
    default = PlaygroundSettings(
        default_prompt_template,
        default_shell,
        default_isolate_shell_history,
        default_isolate_julia_history,
    )

    root = abspath(root)

    PlaygroundCore(
        root,
        joinpath(root, "tmp"),
        joinpath(root, "src"),
        joinpath(root, "bin"),
        joinpath(root, "share"),
        default_playground,
        default_git_address,
        default_git_revision,
        default,
    )
end

"""
    create(core) -> nothing

Creates the necessary filesystem structure needed for a `PlaygroundCore`. Calling the
function on a created core produces no changes.
"""
function create(core::PlaygroundCore)
    mkpath(core.root_dir)

    # Use `mkpath` everywhere in case we have a playground home that isn't self-contained
    mkpath(core.tmp_dir)
    mkpath(core.src_dir)
    mkpath(core.bin_dir)
    mkpath(core.share_dir)

    config_path = joinpath(core.root_dir, "config.yml")
    if !isfile(config_path)  # Avoid overwritting the config file
        open(config_path, "w") do config
            write(config, DEFAULT_CONFIG)
        end
    end

    # TODO: Maybe the playground executable should be installed system wide?
    # playground_exec = joinpath(core.bin_dir, "playground")
    # if !ispath(playground_exec)
    #     mklink(PLAYGROUND_EXEC, playground_exec)
    # end

    return core
end

"""
    load!(core) -> nothing

Updates the settings based upon the contents of the core's configuration file.
"""
function load!(core::PlaygroundCore)
    # open will throw a SystemError if we don't have permissions to read the configuration
    config_path = joinpath(core.root_dir, "config.yml")
    config = YAML.load(open(config_path))

    # Update any setting included in the configuration file.
    core.default_playground = get(config, "default_playground", core.default_playground)
    core.default_git_address = get(config, "default_git_address", core.default_git_address)
    core.default_git_revision = get(config, "default_git_revision", core.default_git_revision)
    core.default.prompt_template = get(config, "prompt", core.default.prompt_template)
    core.default.shell = get(config, "shell", core.default.shell)
    core.default.isolate_shell_history = get(config, "isolated_shell_history", core.default.isolate_shell_history)
    core.default.isolate_julia_history = get(config, "isolated_julia_history", core.default.isolate_julia_history)

    return core
end

function init!(core::PlaygroundCore)
    create(core)  # Safe to do since create does nothing if the core already exists
    load!(core)
    return core
end

function set_core(core::PlaygroundCore)
    global CORE = core
end

global CORE = PlaygroundCore()  # Dummy core
