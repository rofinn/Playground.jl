is_dir_str(dir::AbstractString) = dirname(dir) != ""

function argparse{S<:AbstractString}(args::Array{S}=ARGS)
    parse_settings = ArgParseSettings(
        commands_are_required=true,
        suppress_warnings=true,
    )

    @add_arg_table parse_settings begin
        "create"
            help = "Builds the playground"
            action = :command
        "activate"
            help = "Activates a playground"
            action = :command
        "list"
            help = "Lists available julia versions and playgrounds"
            action = :command
        "rm"
            help = "Deletes the specifid julia-version or playground"
            action = :command
        "install"
            help = "Installs julia version for you"
            action = :command
        "clean"
            help = "Deletes any dead julia-version or playground links, in case you've deleted the original folders"
            action = :command
        "exec"
            help = "Execute a cmd inside a playground and exit"
            action = :command
    end

    @add_arg_table parse_settings["create"] begin
        "name"
            help = "Global name of the playground if `dir` is specified. If `dir` is not specified then `name` will be treated as `dir` when the argument uses a file seperator."
            default = ""  # TODO: Remove when no longer needed
        "dir"
            help = "directory of the new playground"
            default = ""  # TODO: Remove when no longer needed
        "--julia-version", "-j"
            help = "The version(s) of julia available to use. If multiple versions are provided the first entry will be the one used by `julia`. By default the user/system level version is used."
            default = ""
        "--requirements", "-r"
            help = "A REQUIRE or DECLARE file of dependencies to install into the playground."
            default = ""
        "--req-type", "-t"
            help = "If --requirments isn't being passed a path ending in REQUIRE or DECLARE file, please specify which type is it \"REQUIRE\" or \"DECLARE\""
            arg_type = Symbol
            default = :REQUIRE
    end

    parse_settings["create"].epilog = """
    examples:\n
    \n
    Create the global playground "foo"\n
    \ua0\ua0playground create foo    # create the global playground "foo"\n
    \n
    Create a unnamed playground in a specific directory:\n
    \ua0\ua0playground create ./foo  # creates a playground in "./foo"\n
    \ua0\ua0playground create        # creates a playground in "./.playground"\n
    \n
    Create a named playground in a specific directory:\n
    \ua0\ua0playground create foo ./bar  # playground "./bar" named "foo"\n
    """

    @add_arg_table parse_settings["activate"] begin
        "name/dir"
            help = "global name or directory of the playground to activate"
            default = ""
    end

    @add_arg_table parse_settings["list"] begin
        "--show-links", "-s"
            help = "Display the source path if julia-versions or playgrounds are just symlinks."
            action = :store_true
            default = false
    end

    # Note: deletes the playground directory and the global link to it
    @add_arg_table parse_settings["rm"] begin
        "name/dir"
            help = "global name or directory of the playground to delete"
            required = true
    end

    @add_arg_table parse_settings["exec"] begin
        "name/dir"
            help = "global name or directory of the playground to run the command within"
            required = true
        "cmd"
            help = "command you would like to run inside the playground"
            required = true
     end

    @add_arg_table parse_settings["install"] begin
        "download"
            help = "The version of julia you'd like to install from the julia website."
            action = :command
        "link"
            help = "Path to an existing julia build you'd like to use with playgrounds."
            action = :command
        # "build"
        #     help = "The git url to clone the julia source from"
        #     action = :command
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
        "exec"
            help = "The path to a julia executable you'd like to be made available to playgrounds."
            required = true
        "--labels", "-l"
            help = "Extra labels to apply to the new julia versions."
            arg_type = AbstractString
            nargs = '*'
    end

    # @add_arg_table parse_settings["install"]["build"] begin
    #     "url"
    #         help = "The git url to clone the julialang source from. Defaults to https://github.com/JuliaLang/julia.git."
    #         default = ""
    #     "revision"
    #         help = "The revision to checkout prior to building julia. Defaults to origin/master"
    #         default = ""
    #     "--labels", "-l"
    #         help = "Extra labels to apply to the new julia versions."
    #         arg_type = AbstractString
    #         nargs = '*'
    # end

    @add_arg_table parse_settings["clean"]

    results = parse_args(args, parse_settings)

    # Post processing on arguments
    command = results["%COMMAND%"]
    if command == "create"
        if isempty(results["create"]["dir"]) && is_dir_str(results["create"]["name"])
            results["create"]["dir"] = results["create"]["name"]
            results["create"]["name"] = ""
        end
    elseif haskey(results[command], "name/dir")
        name_or_dir = pop!(results[command], "name/dir")

        if is_dir_str(name_or_dir)
            results[command]["name"] = ""
            results[command]["dir"] = name_or_dir
        else
            results[command]["name"] = name_or_dir
            results[command]["dir"] = ""
        end
    end

    return results
end
