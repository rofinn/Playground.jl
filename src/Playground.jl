#VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Playground

using Compat
using ArgParse

include("constants.jl")
include("core.jl")
include("playgroundconfig.jl")
include("versioninfo.jl")
include("utils.jl")
include("args.jl")
include("install.jl")
include("create.jl")
include("activate.jl")
include("execute.jl")
include("list.jl")
include("clean.jl")


export
    # # methods
    # main,
    # load_config,
    # install,
    # dirinstall,
    # gitinstall,
    # create,
    # activate,
    # execute,
    # list,
    # clean,
    # config_path,

    # Constants
    DEFAULT_CONFIG


function main{S<:AbstractString}(cmd_args::Array{S}=ARGS, root::AbstractString="")
    args = argparse(cmd_args)

    cmd = args["%COMMAND%"]
    args = args[cmd]

    if !isempty(root)
        core = PlaygroundCore(root)
        init!(core)
        set_core(core)
    end

    if cmd == "install"
        install_cmd = args["%COMMAND%"]
        args = args[install_cmd]

        if install_cmd == "download"
            julia, version_info = install(args["version"])
            julia_aliases(julia, args["labels"])
        elseif install_cmd == "link"
            julia, version_info = link_install(args["exec"])
            julia_aliases(julia, args["labels"])
        end
    elseif cmd == "create"
        create_playground(
            name=args["name"],
            root=args["dir"],
            julia=args["julia-version"],
            reqs_file=args["requirements"],
            reqs_type=args["req-type"],
        )
    elseif cmd == "activate"
        playground = load_playground(args["dir"], args["name"])
        activate(playground)
    elseif cmd == "exec"
        playground = load_playground(args["dir"], args["name"])
        run(playground, `$(Base.shell_split(args["cmd"]))`)
    elseif cmd == "list"
        list(args["show-links"])
    elseif cmd == "clean"
        clean()
    elseif cmd == "rm"
        playground = load_playground(args["dir"], args["name"])
        remove(playground)
    end
end

end
