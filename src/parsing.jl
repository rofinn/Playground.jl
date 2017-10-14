function argparse(cmd_args=ARGS)
    parse_settings = ArgParseSettings(
        commands_are_required=true,
        suppress_warnings=true,
    )

    @add_arg_table parse_settings begin
        "--debug", "-d"
            help = "Log debug message to STDOUT"
            action = :store_true
            default = false
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
        "clean"
            action = :command
            help = "Deletes any dead julia-version or playground links, in case you've deleted the original folders."
        "rm"
            help = "Deletes the specifid julia-version or playground."
            action = :command
        "exec"
            action = :command
            help = "Execute a cmd inside a playground and exit."
    end

    @add_arg_table parse_settings["install"] begin
        "download"
            action = :command
            help = "The version of julia you'd like to install from the julia website."
        "link"
            action = :command
            help = "Path to an existing julia build you'd like to use with playgrounds."
        # "build"
        #     action = :command
        #     help = "The git url to clone the julia source from"
    end

    @add_arg_table parse_settings["create"] begin
        "dir"
            help = "Where to create the playground. Defaults to the current working directory (can be changed in `~/.playground/config`."
            arg_type = AbstractPath
            default = Path()
        "--requirements", "-r"
            help = "A REQUIRE or DECLARE file of dependencies to install into the playground."
            arg_type = AbstractPath
            default = Path()
        "--name", "-n"
            help = "A global name to allow activating the playground from anywhere."
            default = ""
        "--julia-version", "-j"
            help = "The version(s) of julia available to use. If multiple versions are provided the first entry will be the one used by `julia`. By default the user/system level version is used."
            default = ""
        "--julia-metadata", "-m"
            help = "The url of the METADATA repo to be cloned when initializing the package directory."
            default = ""
        "--julia-meta-branch", "-b"
            help = "The branch of the METADATA repo check out."
            default = ""

    end

    @add_arg_table parse_settings["activate"] begin
        "dir"
            help = "The path to the playground to use. This takes priority over --name."
            arg_type = AbstractPath
            default = Path()
        "--name", "-n"
            help = "A global name to allow activating the playground from anywhere."
            default = ""
    end

    @add_arg_table parse_settings["exec"] begin
        "cmd"
            help = "The command you would like to run inside the playground."
            required = true
        "dir"
            help = "The path to the playground to use. This takes priority over --name."
            arg_type = AbstractPath
            default = Path()
        "--name", "-n"
            help = "A global name to allow activating the playground from anywhere."
            default = ""
    end

    @add_arg_table parse_settings["list"] begin
        "--show-links", "-s"
            help = "Display the source path if julia-versions or playgrounds are just symlinks."
            action = :store_true
            default = false
    end

    @add_arg_table parse_settings["clean"]

    @add_arg_table parse_settings["rm"] begin
        "name"
            help = "Deletes the playground directory with the given name and the link to it."
            default = ""
        "--dir"
            help = "Deletes the provided playground directory and the link to it."
            arg_type = AbstractPath
            default = Path()
    end

    @add_arg_table parse_settings["install"]["download"] begin
        "version"
            help = "The release version available to download at http://julialang.org/downloads/"
            arg_type = VersionNumber
            required = true
        "--labels", "-l"
            help = "Extra labels to apply to the new julia versions."
            arg_type = AbstractString
            nargs = '*'
    end

    @add_arg_table parse_settings["install"]["link"] begin
        "dir"
            help = "The path to a julia executable you'd like to be made available to playgrounds."
            arg_type = AbstractPath
            default = Path()
        "--labels", "-l"
            help = "Extra labels to apply to the new julia versions."
            arg_type = AbstractString
            nargs = '*'
    end

    # @add_arg_table parse_settings["install"]["build"] begin
    #     "url"
    #         help = "The git url to clone the julialang source from. Defaults to https://github.com/JuliaLang/julia.git"
    #         default = ""
    #     "revision"
    #         help = "The revision to checkout prior to building julia. Defaults to origin/master"
    #         default = ""
    #     "--labels", "-l"
    #         help = "Extra labels to apply to the new julia versions."
    #         arg_type = AbstractString
    #         nargs = '*'
    # end

    return parse_args(cmd_args, parse_settings)
end
