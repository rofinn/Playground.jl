#VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Playground

using Compat
using ArgParse
using Mocking
using FilePaths
using Memento

include("constants.jl")
include("config.jl")
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
    load_config,
    install,
    create,
    activate,
    execute,
    list,
    clean,
    config_path,

    # Constants
    DEFAULT_CONFIG


const logger = get_logger(current_module())

function main(cmd_args=ARGS, config=Path(), root=Path())
    if isempty(config) && isempty(root)
        config = join(config_path(), p"config.yml")
        root = config_path()
    end

    args = argparse(cmd_args)

    cmd = args["%COMMAND%"]
    log_level = args["debug"] ? "debug" : "info"
    Memento.config(log_level; fmt="[{level}] {msg}")

    args = args[cmd]

    config = load_config(config, root)

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
            config;
            dir=args["dir"],
            name=args["name"],
            julia=args["julia-version"],
            reqs_file=args["requirements"],
        )
    elseif cmd == "activate"
        activate(
            config;
            dir=args["dir"],
            name=args["name"],
        )
    elseif cmd == "exec"
        execute(
            config,
            `$(Base.shell_split(args["cmd"]))`;
            dir=args["dir"],
            name=args["name"],
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
