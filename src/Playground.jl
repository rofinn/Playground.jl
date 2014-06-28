#!/usr/bin/env julia

using ArgParse

include("utils.jl")

JULIA_GIT_ADDRESS = "https://github.com/JuliaLang/julia.git"
ACTIVATED_PROMPT = "playground> "

# The main function is only called from the
# virtenv script.
function main()
    parse_settings = ArgParseSettings()

    @add_arg_table parse_settings begin
        "--verbose", "-v"
            help = "increase verbosity"
            action = :count_invocations
        "--quiet", "-q"
            help = "decrease verbosity"
            action = :count_invocations
        "directory"
            help = "The path for the virtualenv directory."
            required = true
        "create"
            action = :command
            help = "builds th playground"
        "activate"
            action = :command
            help = "activates the playground"
        #"deactivate"
        #    action = :command
        #    help = "deactivates the playground"
    end

    @add_arg_table parse_settings["create"] begin
        "--julia", "-j"
            help = "The version of julia to use.  You can pass in either the julia version number which will build a fresh version of julia in the virtualenv or you can pass a prebuilt system path to use.  By default the user/system level version is used."
            action = :store_arg
            default = ""
        "--clear", "-c"
            help = "Clear out the virtualenv and rebuild it from scratch."
            action = :store_true
    end

    args = parse_args(parse_settings)

    cmd = args["%COMMAND%"]
    if cmd == "create"
        create(args["directory"], args[cmd]["julia"], args[cmd]["clear"])
    elseif cmd == "activate"
        activate(args["directory"])
    #elseif cmd == "deactivate"
    #    deactivate()
    end
end

# NOTE: for now builddeps.jl should add the playground path to ~/.bashrc or ~/.zshrc

# Initializes all of the base paths in the playground
# eg - bin, lib, src, etc
# Handles building julia
function create(directory, julia, clear)
    root_path = abspath(directory)
    bin_path = joinpath(root_path, "bin")
    pkg_path = joinpath(root_path, "packages")
    julia_path = joinpath(bin_path, "julia")
    julia_src_path = joinpath(root_path, "julia_src")

    mkpath(root_path)
    mkpath(bin_path)
    mkpath(pkg_path)

    # Only deal with setting up julia if the julia argument
    # was set
    if julia != ""
        # args.julia is a path to an existing julia version
        if ispath(julia)
            mklink(julia, julia_path)
        # otherwise is julia isn't empty then we are going to need
        # to clone julia and build it from a particular rev or tag
        else
            run(`git clone $(JULIA_GIT_ADDRESS) $(julia_src_path)`)
            cd(build_julia(julia), julia_path)
        end
    end
end

# Nix : zsh and bash
# windows: cmd /K prompt "blah"
function activate(directory)
    root_path = abspath(directory)
    bin_path = joinpath(root_path, "bin")
    pkg_path = joinpath(root_path, "packages")

    ENV["PATH"] = "$(bin_path):", ENV["PATH"]
    ENV["JULIA_PKGDIR"] = pkg_path

    @windows? run_windows_shell() : run_nix_shell()
end

function build_julia(target, prefix)
    # args.julia is a julia version
    if '.' in args.julia
        run(`git checkout $(target) -- .`)
    # assume args.julia is a git sha
    # regex from http://stackoverflow.com/questions/468370/a-regex-to-match-a-sha1
    elseif ismatch(r"/\b([a-f0-9]{40})\b/", args.julia)
        run(`git checkout -b args.julia args.julia`)
    end

    # Write the different prefix to the Make.user file before
    # building and installing.
    fstrm = open(joinpath(julia_src_path, "Make.user"),"w")
    write(fstrm, "prefix=$(root_path)/")

    # Build and install.
    # TODO: log the build output properly in root_dir/log
    run(`make`)
    run(`make install`)
end

function run_windows_shell()
    run(`cmd /K prompt $(ACTIVATED_PROMPT)`)
end

function run_nix_shell()
    ENV["PS1"] = ACTIVATED_PROMPT
    run(`sh -i`)
end

main()
