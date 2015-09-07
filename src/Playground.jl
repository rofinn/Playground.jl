module Playground

using ArgParse
using Logging

include("constants.jl")
include("config.jl")
include("install.jl")
include("utils.jl")
include("create.jl")
include("activate.jl")


export main, Config, init, install, dirinstall, gitinstall, binurls


function main()
    parse_settings = ArgParseSettings()

    @add_arg_table parse_settings begin
        "install"
            action = :command
            help = "Installs julia version for you."
        "create"
            action = :command
            help = "Builds the playground"
        "activate"
            action = :command
            help = "Activates the playground."
        "list"
            action = :command
            help = "Lists available julia versions and playgrounds"
    end

    @add_arg_table parse_settings["install"] begin
        "download"
            action = :command
            help = "The version of julia you'd like to install from the julia website."
        "link"
            action = :command
            help = "Path to an existing julia build you'd like to use with playgrounds."
        "build"
            action = :command
            help = "The git url to clone the julia source from"
        "--labels", "-l"
            help = "Extra labels to apply to the new julia verions."
            nargs = '*'
            action = :store_arg
            default = []
    end

    @add_arg_table parse_settings["create"] begin
        "dir"
            help = "Where to create the playground. Defaults to the current working directory (can be changed in `~/.playground/config`."
            action = :store_arg
            default = ""
        "--requirements", "-r"
            help = "A REQUIRE or DECLARE file of dependencies to install into the playground."
            action = :store_arg
            default =""
        "--name", "-n"
            help = "A global name to allow activating the playground from anywhere."
            action = :store_arg
            default = ""
        "--julia-versions", "-j"
            help = "The version(s) of julia available to use. If multiple versions are provided the first entry will be the one used by `julia`. By default the user/system level version is used."
            nargs = '*'
            action = :store_arg
            default = ""
    end

    @add_arg_table parse_settings["activate"] begin
        "dir"
            help = "The path to the playground to use. This takes priority over --name."
            action = :store_arg
            default = ""
        "--name", "-n"
            help = "A global name to allow activating the playground from anywhere."
            action = :store_arg
            default = ""
    end

    @add_arg_table parse_settings["list"] begin
        "--julia-versions", "-j"
            help = "Display julia versions avaiable."
            action = :store_true
            default = ""
        "--playgrounds", "-p"
            help = "Display playgrounds."
            action = :store_true
            default = ""
    end

    @add_arg_table parse_settings["install"]["download"] begin
        "version"
            help = "The release version available to download at http://julialang.org/downloads/"
            required = true
    end

    @add_arg_table parse_settings["install"]["link"] begin
        "dir"
            help = "The path to a julia executable you'd like to be made available to playgrounds."
            required = true
    end

    @add_arg_table parse_settings["install"]["build"] begin
        "url"
            help = "The git url to clone the julialang source from. Defaults to https://github.com/JuliaLang/julia.git"
            action = :store_arg
            default = ""
        "revision"
            help = "The revision to checkout prior to building julia. Defaults to origin/master"
            default = ""
    end

    args = parse_args(parse_settings)

    cmd = args["%COMMAND%"]

    config = load_config(joinpath(homedir(), ".playground/config.yml"))

    # Should handle proper loading of config from here.

    if cmd == "install"
        install_cmd = args[cmd]["%COMMAND%"]

        if install_cmd == "download"
            install(
                VersionNumber(args[cmd][install_cmd]["version"]),
                config;
                labels=args[cmd]["labels"]
            )
        elseif install_cmd == "link"
            dirinstall(
                abspath(args[cmd][install_cmd]["dir"]),
                config;
                labels=args[cmd]["labels"]
            )
        elseif install_cmd == "build"
            error("Building from source isn't supported yet.")
        end
    elseif cmd == "create"
        create(
            args[cmd]["dir"], args[cmd]["julia-versions"],
            args[cmd]["name"], args[cmd]["requirements"], config
        )
    elseif cmd == "activate"
        activate(args[cmd]["dir"], args[cmd]["name"], config)
    end
end

end
