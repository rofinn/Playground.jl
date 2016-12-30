#VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Playground

using Compat
using ArgParse
using Mocking

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
    dirinstall,
    #gitinstall,
    create,
    activate,
    execute,
    list,
    clean,
    config_path,

    # Constants
    DEFAULT_CONFIG



function main(cmd_args=ARGS, config="", root="")
    if config == "" && root == ""
        config = joinpath(config_path(), "config.yml")
        root = config_path()
    end

    args = argparse(cmd_args)

    cmd = args["%COMMAND%"]
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
            dirinstall(
                config,
                abspath(args["dir"]);
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
