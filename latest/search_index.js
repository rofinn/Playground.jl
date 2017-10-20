var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Playground.jl",
    "title": "Playground.jl",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Playground.jl-1",
    "page": "Playground.jl",
    "title": "Playground.jl",
    "category": "section",
    "text": "(Image: Build Status) (Image: codecov.io) (Image: Project Status: Active - The project has reached a stable, usable state and is being actively developed.)A package for managing julia sandboxes like python's virtualenv (with a little influence from pyenv and virtualenvwrapper)Supports: (Image: StatsBase) (Image: StatsBase)"
},

{
    "location": "index.html#Installation-1",
    "page": "Playground.jl",
    "title": "Installation",
    "category": "section",
    "text": "You can install Playground.jl with Pkg.add.julia> Pkg.add(\"Playground\")If you'd like to install the playground script and config.yml file to the shared ~/.playground directory run:julia> ENV[\"PLAYGROUND_INSTALL\"] = true; Pkg.build(\"Playground\")The playground script is now ready to use.> ~/.playground/bin/playground -h\nusage: <PROGRAM> [-d] [-h]\n                 {install|create|activate|list|clean|rm|exec}\n\ncommands:\n  install      Installs julia version for you.\n  create       Builds the playground\n  activate     Activates the playground.\n  list         Lists available julia versions and playgrounds\n  clean        Deletes any dead julia-version or playground links, in\n               case you've deleted the original folders.\n  rm           Deletes the specifid julia-version or playground.\n  exec         Execute a cmd inside a playground and exit.\n\noptional arguments:\n  -d, --debug  Log debug message to STDOUT\n  -h, --help   show this help message and exitRecommended: Add the playground bin directory to your path by editing your ~/.bashrc, ~/.zshrc, ~/.tcshrc, etc.echo \"PATH=$PATH:~/.playground/bin/\" >> ~/.bashrcThis will make the playground script and all managed julia versions easily accessible.NOTE: You may want to modify the shebang (e.g., #!/usr/bin/env julia) in ~/.playground/bin/playground to either ignore deprecation warnings or improve load times.Add --depwarn=no to ignore deprecation warnings.\nAdd --optimize=0 to speed up load times.If you're running linux you'll need to use the path to the julia executable directly (e.g. #!/usr/bin/julia --depwarn=no --optimize=0) as env in linux can only take 1 argument, otherwise the process will stall. You can get the path to your julia executable with /usr/bin/env julia."
},

{
    "location": "index.html#Overview-1",
    "page": "Playground.jl",
    "title": "Overview",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Configuration-1",
    "page": "Playground.jl",
    "title": "Configuration",
    "category": "section",
    "text": "For the most part, Playground.jl provide its virtualized environments by simply manipulating environment variables and symlinks to julia binaries/playgrounds. However, in order to do this it needs to create its own folder for managing these symlinks. By default Playground.jl creates its own config folder in ~/.playground. This folder is structured as follows.|-- .playground/\n    |-- config.yml\n    |-- bin/\n        |-- playground\n        |-- julia\n        |-- julia-stable\n        |-- julia-nightly\n        |-- julia-0.3\n        |-- julia-0.4\n        ...\n    |-- share/\n        |-- myproject\n        |-- testing\n        |-- research\n    |-- src/\n        |-- julia-038-osx10\n            ...\n    |-- tmp/\n        |-- julia-0.3.8-osx10.7+.dmgbin: contains all the symlinks to installed julia versions (and also the playground script itself)\nshare: contains all the named playgrounds or links to named playgrounds.\nsrc: contains the extracted binary builds and cloned julia repos.\ntmp: just contains the raw julia binary downloads"
},

{
    "location": "index.html#config.yml-1",
    "page": "Playground.jl",
    "title": "config.yml",
    "category": "section",
    "text": "The config.yml file provides a mechanism for configuring default behaviour. This file is setup during installation.---\n# This is just default location to store a new playground.\n# This is used by create and activate if no --name or --path.\ndefault_playground_path: .playground\n\n# Default shell prompt when you activate a playground.\ndefault_prompt: \"\\\\e[0;35m\\\\u@\\\\h:\\\\W (playground)> \\\\e[m\"\n\n# Default git settings when using install build\ndefault_git_address: \"https://github.com/JuliaLang/julia.git\"\ndefault_git_revision: master\n\n# Allows you to isolate shell and julia history to each playground.\nisolated_shell_history: true\nisolated_julia_history: true"
},

{
    "location": "index.html#TODOs-1",
    "page": "Playground.jl",
    "title": "TODOs",
    "category": "section",
    "text": "Full windows support including install\ninstall build support."
},

{
    "location": "binaries.html#",
    "page": "Binary Releases",
    "title": "Binary Releases",
    "category": "page",
    "text": ""
},

{
    "location": "binaries.html#Binary-Releases-1",
    "page": "Binary Releases",
    "title": "Binary Releases",
    "category": "section",
    "text": "As of v0.0.6 and up binary releases of playground are available for download here, which will allow you to run playground without having an existing julia install."
},

{
    "location": "binaries.html#Installing-1",
    "page": "Binary Releases",
    "title": "Installing",
    "category": "section",
    "text": "Download the tar.gz file for your platform into your desired install location (ie: ~/bin)\nGo to that directory (cd ~/bin)\nExtract the build (tar -xvzf ~/bin/playground-osx.tar.gz)\ncd playground && ./INSTALL.sh\nCreate an alias that sets the LD_LIBRARY_PATH and calls the script. This should be placed in your shell rc file, so if your default shell is bash then you'd add alias playground=\"LD_LIBRARY_PATH=~/bin/playground ~/bin/playground/playground\" to your ~/.bashrc file.NOTE: This alias hack with LD_LIBRARY_PATH is only necessary due to an issue in the binaries created with BuildExecutable.jl. In future releases it should only be necessary for ~/bin/playground to be on your search path (ie: in your PATH variable)."
},

{
    "location": "binaries.html#Building-1",
    "page": "Binary Releases",
    "title": "Building",
    "category": "section",
    "text": "If you'd like to build you own playground binary executables you'll have a few more steps. First, add BuildExecutable and checkout the current master.julia> Pkg.add(\"BuildExecutable\")\n\njulia> Pkg.checkout(\"BuildExecutable.jl\")In order to tell the Playground.jl build script to create a binary executable you'll need to runjulia> ENV[\"PLAYGROUND_BIN_EXEC\"] = trueprior to calling Pkg.build(\"Playground\")."
},

{
    "location": "executable.html#",
    "page": "Executable",
    "title": "Executable",
    "category": "page",
    "text": ""
},

{
    "location": "executable.html#Executable-1",
    "page": "Executable",
    "title": "Executable",
    "category": "section",
    "text": "The primary interface provided by Playground.jl is via the playground executable, which includes several subcommands for manipulating playground environments.> playground -h\nusage: <PROGRAM> [-d] [-h]\n                 {install|create|activate|list|clean|rm|exec}\n\ncommands:\n  install      Installs julia version for you.\n  create       Builds the playground\n  activate     Activates the playground.\n  list         Lists available julia versions and playgrounds\n  clean        Deletes any dead julia-version or playground links, in\n               case you've deleted the original folders.\n  rm           Deletes the specifid julia-version or playground.\n  exec         Execute a cmd inside a playground and exit.\n\noptional arguments:\n  -d, --debug  Log debug message to STDOUT\n  -h, --help   show this help message and exit"
},

{
    "location": "executable.html#install-(Unix-only)-1",
    "page": "Executable",
    "title": "install (Unix only)",
    "category": "section",
    "text": "To install a binary julia version from https://julialang-s3.julialang.org.# playground install download <version> --labels label1 label2\nplayground install download 0.3 --labels julia-0.3To make an existing build available to playgrounds.# playground install link <path> --labels label1 label2\nplayground install link /path/to/julia/binary --labels julia-src[TODO] To build and install a julia version from source.playground install build --url https://github.com/MyUser/julia.git --rev dev --labels julia-wipThis is less of a priority as most individuals can just manually build from source and use playground install link to make their build available. Similarly, this particular subcommand will be more brittle as it depends on the success of the julia build process.NOTE: Along with the provided labels, all install cmds will automatically create symlinks for the full version and commit eg: julia-0.3.11 and julia-128797f."
},

{
    "location": "executable.html#create-1",
    "page": "Executable",
    "title": "create",
    "category": "section",
    "text": "To create a new playground using your existing julia install in your current working directory.playground createThis will automatically create a .playground folder (default specified in ~/.playground/config.yml)To create a new playground in a specific directory.playground create /path/of/new/playgroundAlternatively, you can name your playgrounds to make them available without remembering where they're stored.playground create --name research-playgroundNOTE: If both a directory and a --name are supplied the playground will be created in the provided directory and linked to ~/.playground/share/<name>. Otherwise, the playground will be created directly in ~/.playground/share/<name>.To create a playground with a default julia-version. The julia version supplied must already be installed with methods listed above.playground create /path/of/new/playground --name nightly-playground --julia-version julia-nightlyTo create a new playground with pre-existing requirements using REQUIRE or DECLARE files.playground create --requirements /path/to/REQUIRE/or/DECLARE/fileIf the basename of the file is not REQUIRE or DECLARE you can still specify the requirement type.playground create --requirements /path/to/requirements/file --req-type DECLAREIf using DECLARE files you should make sure that DeclarativePackages.jl is already installed."
},

{
    "location": "executable.html#activate-1",
    "page": "Executable",
    "title": "activate",
    "category": "section",
    "text": "To activate a given playground simply run.playground activate /path/to/your/playgroundorplayground activate --name myprojectNOTE: On Unix systems, activate will try and open a new shell using you SHELL environment variable and a modified copy of your ~/.<shell>rc file. Otherwise, it will fall back to using sh -i."
},

{
    "location": "executable.html#list-1",
    "page": "Executable",
    "title": "list",
    "category": "section",
    "text": "To see what install julia-versions and playgrounds (named ones) are available.playground list"
},

{
    "location": "executable.html#clear-1",
    "page": "Executable",
    "title": "clear",
    "category": "section",
    "text": "If you've removed some a source julia-version or have deleted playground folders and would like playground to clean up any broken symlinks.playground clean"
},

{
    "location": "executable.html#rm-1",
    "page": "Executable",
    "title": "rm",
    "category": "section",
    "text": "If you'd like to remove a julia-version or playground you can run.playground rm [playground-name|julia-version] --dir /path/to/playgroundswhich will delete the specified playground or julia-version and make sure that all related links have been cleaned up. Warning: Deleting julia versions may break playgrounds that depend on that version. If this occurs you can either manually recreate the julia symlink with ln -s ~/.playground/bin/<julia-version> /path/to/playground/bin/julia or better yet recreate the playground."
},

{
    "location": "repl.html#",
    "page": "REPL",
    "title": "REPL",
    "category": "page",
    "text": ""
},

{
    "location": "repl.html#REPL-1",
    "page": "REPL",
    "title": "REPL",
    "category": "section",
    "text": "All of the functionality provided by the playground executable can be accessed with the exported API.NOTES:This API is still under development and while the functionality is largelystable the exactly interface is still subject to change.Playground differentiates Strings and Paths using the AbstractPath type providedby FilePaths.jl. A path type can be created with p\"/path/to/my/thing\".Memento logging can be configured for debugging purposes.julia> using Memento\n\njulia> Memento.config(\"debug\")"
},

{
    "location": "repl.html#Config-1",
    "page": "REPL",
    "title": "Config",
    "category": "section",
    "text": "Stores information about the shared configuration directory. The easiest way to get a Config instances is with:julia> config = Config()    # Uses the default config at ~/.playground/config.yml"
},

{
    "location": "repl.html#Environment-1",
    "page": "REPL",
    "title": "Environment",
    "category": "section",
    "text": "Methods that only operate on playground environments (e.g., create, activate) can also take an Environment type. In future releases, the Environment type may be abstracted into an interface that supports different methods of isolation (e.g., DockerEnvironment for maintaining julia docker environments).Example)julia> env = Environment(\"research\")    # A shared environment named \"research\"\n\n# Create the research environment\njulia> create(env)\n\n# Activate the research environment in our current REPL\njulia> activate(env; shell=false)\n\nresearch> Pkg.dir()\n\"/Users/rory/.playground/share/research/packages/v0.6\"\n\nresearch> deactivate()\n\njulia> Pkg.dir()\n\"/Users/rory/.julia/v0.6\"\n\njulia> withenv(env) do\n           Pkg.dir()\n       end\n\"/Users/rory/.playground/share/research/packages/v0.6\""
},

{
    "location": "repl.html#install-(Unix-only)-1",
    "page": "REPL",
    "title": "install (Unix only)",
    "category": "section",
    "text": "To install a binary julia version from http://julialang.org/downloads/.julia> install(config, v\"0.7.0-\"; labels=[\"julia-0.7\"])To make an existing build available to playgrounds.julia> install(config, p\"/path/to/julia/binary\"; labels=[\"julia-src\"])"
},

{
    "location": "repl.html#create-1",
    "page": "REPL",
    "title": "create",
    "category": "section",
    "text": "To create a new playground using your existing julia install in your current working directory.julia> create()This will automatically create a .playground folder (default specified in ~/.playground/config.yml)To create a new playground in a specific directory.julia> create(config, p\"/path/of/new/playground\")To name your playgrounds and make them available without remembering where they're stored.julia> create(config, \"research-playground\")Create a playground with a default julia-version.julia> create(config, p\"/path/of/new/playground\", \"nightly-playground\"; julia=\"julia-nightly\")Create a new playground with pre-existing REQUIRE file.julia> create(; p\"/path/to/REQUIRE\")"
},

{
    "location": "repl.html#activate-1",
    "page": "REPL",
    "title": "activate",
    "category": "section",
    "text": "To activate a given playground simply run.julia> activate(config, p\"/path/to/your/playground\")orjulia> activate(config, \"myproject\")NOTE: On Unix systems, activate will by default try and open a new shell using you SHELL environment variable and a modified copy of your ~/.<shell>rc file. Otherwise, it will fall back to using sh -i.If you'd like to work within a playground environment from your current REPL just pass shell=false.julia> activate(config, \"myproject\"; shell=false)"
},

{
    "location": "repl.html#list-1",
    "page": "REPL",
    "title": "list",
    "category": "section",
    "text": "To see what install julia-versions and playgrounds (named ones) are available.julia> list(config)"
},

{
    "location": "repl.html#clear-1",
    "page": "REPL",
    "title": "clear",
    "category": "section",
    "text": "If you've removed some a source julia-version or have deleted playground folders and would like playground to clean up any broken symlinks.julia> clean(config)"
},

{
    "location": "repl.html#rm-1",
    "page": "REPL",
    "title": "rm",
    "category": "section",
    "text": "If you'd like to remove a julia-version or playground you can run.julia> rm(config, \"myproject\")orjulia> rm(config, \"julia-0.7\")which will delete the specified playground or julia-version and make sure that all related links have been cleaned up.Reminder: Deleting julia versions may break playgrounds that depend on that version."
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#Playground.Config",
    "page": "API",
    "title": "Playground.Config",
    "category": "Type",
    "text": "Config(; file=p\"~/.playground/config.yml\", root=p\"~/.playground\")\n\nStores various default playground environment settings including paths for storing shared binaries and environments.\n\n\n\n"
},

{
    "location": "api.html#Playground.Environment",
    "page": "API",
    "title": "Playground.Environment",
    "category": "Type",
    "text": "Environment([config::Config], [name::String], [root::AbstractPath])\n\nAn environment stores information about a playground environment and provides methods fro interacting with them.\n\nNOTE: In the future we might want to support different types of environments (e.g., DockerEnvironment).\n\n\n\n"
},

{
    "location": "api.html#Playground.install",
    "page": "API",
    "title": "Playground.install",
    "category": "Function",
    "text": "install{S<:AbstractString}(config::Config, version::VersionNummber; labels::Array{S}=String[])\n\nDownloads the latest binary version for your platform and symlinks the binary with the appropriate labels.\n\n\n\ninstall{S<:AbstractString}(config::Config, executable::AbstractPath; labels::Array{S}=String[])\n\nCreates symlinks from an existing julia install.\n\n\n\n"
},

{
    "location": "api.html#Playground.create",
    "page": "API",
    "title": "Playground.create",
    "category": "Function",
    "text": "create(; kwargs...)\ncreate(config::Config, args...; kwargs...)\ncreate(env::Environment; kwargs...)\n\nCreates a new playground Environment including initializing its package directory and installing any package in the REQUIRE file passed in.\n\nOptional Arguments\n\nYou can optionally pass in an Environment instance of a Config and args to build one.\n\nKeywords Arguments\n\njulia::AbstractString - a julia binary to use in this playground environment.\nreqs_file::AbstractPath - path to a REQUIRE file of packages to install in this environment.\nregistry::AbstractString - url to the package registry to be cloned.\nbranch::AbstractString - registry branch to be checked out.\n\n\n\n"
},

{
    "location": "api.html#Playground.activate",
    "page": "API",
    "title": "Playground.activate",
    "category": "Function",
    "text": "activate(; shell=true)\nactivate(config::Config, args...; shell=true)\nactivate(env::Environment; shell=true)\n\nModifies the current environment to operate within a specific playground environment. When shell=true a new shell environment will be created. However, when shell=false the existing julia REPL will be modifed and deactivate() must be called to restore the REPL state.\n\n\n\n"
},

{
    "location": "api.html#Playground.deactivate",
    "page": "API",
    "title": "Playground.deactivate",
    "category": "Function",
    "text": "deactivate()\n\nDeactivates the active environment and restores the original julia environment.\n\n\n\n"
},

{
    "location": "api.html#Base.withenv-Tuple{Function,Playground.Environment}",
    "page": "API",
    "title": "Base.withenv",
    "category": "Method",
    "text": "withenv(f::Function, env::Environment)\n\nWorks the same as withenv(f, keyvals...), but is specific to running f within a playground Environment.\n\n\n\n"
},

{
    "location": "api.html#Playground.list",
    "page": "API",
    "title": "Playground.list",
    "category": "Function",
    "text": "list(config::Config; show_links=false)\n\nPrints out all installed julia version and playgrounds.\n\n\n\n"
},

{
    "location": "api.html#Playground.clean",
    "page": "API",
    "title": "Playground.clean",
    "category": "Function",
    "text": "clean(config::Config)\n\nRemoves any deadlinks Playground's bin and share directories.\n\n\n\n"
},

{
    "location": "api.html#Base.Filesystem.rm-Tuple{Playground.Config}",
    "page": "API",
    "title": "Base.Filesystem.rm",
    "category": "Method",
    "text": "rm(config::Config; name::AbstractString=\"\", dir::AbstractPath=Path())\n\nRemoves a julia binary or playground from Playground's bin and share directories.\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "Config\nEnvironment\ninstall\ncreate\nactivate\ndeactivate\nwithenv(::Function, ::Environment)\nlist\nclean\nrm(::Config)"
},

]}
