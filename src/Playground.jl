__precompile__()

module Playground

using Compat
using ArgParse
using Mocking
using FilePaths
using Memento

include("constants.jl")
include("repl.jl")
include("shell.jl")
include("config.jl")
include("env.jl")
include("utils.jl")
include("parsing.jl")
include("install.jl")
include("create.jl")
include("activate.jl")
include("execute.jl")
include("list.jl")
include("clean.jl")


export
    # methods
    main,
    argparse,
    install,
    create,
    activate,
    deactivate,
    execute,
    list,
    clean,

    # Constants
    DEFAULT_CONFIG,

    # Types
    Config,
    Environment


const logger = get_logger(current_module())
const cache = Vector{Dict{Symbol, Any}}()

function main(cmdargs, configargs...)
    args = argparse(cmdargs)

    cmd = args["%COMMAND%"]
    log_level = args["debug"] ? "debug" : "info"
    Memento.config(log_level; fmt="[ {level} ] {msg}")

    args = args[cmd]

    config = Config(configargs...)

    debug(logger, "Arguments: $args")
    if cmd == "install"
        install_cmd = args["%COMMAND%"]
        args = args[install_cmd]

        if install_cmd == "download"
            install(
                config,
                args["version"];
                labels=args["labels"],
            )
        elseif install_cmd == "link"
            install(
                config,
                abs(args["dir"]);
                labels=args["labels"],
            )
        # elseif install_cmd == "build"
        #     error("Building from source isn't supported yet.")
        end
    elseif cmd == "create"
        create(
            config,
            args["dir"],
            args["name"];
            julia=args["julia-version"],
            reqs_file=args["requirements"],
        )
    elseif cmd == "activate"
        activate(
            config,
            args["dir"],
            args["name"],
        )
    elseif cmd == "exec"
        execute(
            `$(Base.shell_split(args["cmd"]))`,
            config,
            args["dir"],
            args["name"],
        )
    elseif cmd == "list"
        list(
            config;
            show_links=args["show-links"],
        )
    elseif cmd == "clean"
        clean(config)
    elseif cmd == "rm"
        rm(
            config;
            name=args["name"],
            dir=args["dir"],
        )
    end
end

end
