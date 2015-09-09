Playground.jl
=============
[![Build Status](https://travis-ci.org/Rory-Finnegan/Playground.jl.svg)](https://travis-ci.org/Rory-Finnegan/Playground.jl)

A package for managing julia sandboxes like python's virtualenv (with a little influence from pyenv and virtualenvwrapper)

### Installation ###
Install the julia package
```shell
julia>Pkg.add("Playground")
```
Running the playground script
```shell
~/.playground/bin/playground
```
Recommended: add the playground bin directory to your path 
by editing your ~/.bashrc, ~/.zshrc, ~/.tcshrc, etc.
```shell
echo "PATH=~/.playground/bin/:$PATH" >> ~/.bashrc
```
This will make the playground script and all managed julia versions easily accessible.

### Usage ###
#### Install (Unix only) ####
To install a binary julia version from http://julialang.org/downloads/
```shell
# playground install download <version> --labels label1 label2
playground install download 0.3 --labels julia-0.3
```

To make an existing build available to playgrounds
```shell
# playground install link <path> --labels label1 label2
playground install link /path/to/julia/binary --labels julia-src
```

[TODO] To build and install a julia version from source
```shell
playground install build --url https://github.com/MyUser/julia.git --rev dev --labels julia-wip
```
This is less of a priority as most individuals can just manual build from source and use `playground install link` to make their build available. Similarly, this particular subcommand will be more brittle as it depends on the success of the julia build process.

NOTE: Along with the provided labels, all install cmds will automatically create symlinks for the full version and commit eg: `julia-0.3.11` and `julia-128797f`.


#### Create ####
To create a new playground using your existing julia install in your current working directory.
```shell
playground create
```
This will automatically create a `.playground` folder (default specified in `~/.playground/config.yml`)

To create a new playground in a specific directory.
```shell
playground create /path/of/new/playground
```

Alternatively, you can name your playgrounds to make them available without remembering where they're stored.
```shell
playground create --name research-playground
```
NOTE: If both a directory and a `--name` are supplied the playground will be created in the provided directory and linked to `~/.playground/share/<name>`. Otherwise, the playground will be created directly in `~/.playground/share/<name>`.

To create a playground with a default julia-version. The julia version supplied must already be installed with methods listed above.
```shell
playground /path/of/new/playground create --name nightly-playground --julia-version julia-nightly
```

To create a new playground with pre-existing requirements using REQUIRE or DECLARE files.
```shell
playground create --requirements /path/to/REQUIRE/or/DECLARE/file
```
If the basename of the file is not `REQUIRE` or `DECLARE` you can still specify the requirement type
```shell
playground create --requirements /path/to/requirements/file --req-type DECLARE
```
If using DECLARE files you should make sure that `DeclarativePackages.jl` is already installed.


#### Activate ####
To activate a given playground simply run.
```shell
playground activate /path/to/your/playground
```
or
```shell
playground activate --name myproject
```

NOTE: On Unix systems, activate will try and open a new shell using you SHELL environment variable and a modified copy of your `~/.<shell>rc` file. Otherwise, it will fall back to using `sh -i`.

#### List ####
To see what install julia-versions and playgrounds (named ones) are available.
```shell
playground list
```


#### Clear ####
If you've removed some a source julia-version or have deleted playground folders and would like playground to clean up any broken symlinks simply run
```shell
playground clear links
```

Alternatively, if you'd like to remove a julia-version or playground you can run.
```shell
playground clear rm [playground-name|julia-version] --dir /path/to/playgrounds
```
which will delete the specified playground or julia-version and make sure that all related links have been cleaned up.


### Configuration ###
For the most part, Playground.jl provide its virtualized environments by simply manipulating environment variables and symlinks to julia binaries/playgrounds. However, in order to do this it needs to create its own folder for managing these symlinks. By default Playground.jl creates its own config folder in `~/.playgournd`. This folder is structured as follows.
```
|-- .playground/
    |-- config.yml
    |-- bin/
        |-- playground
        |-- julia
        |-- julia-stable
        |-- julia-nightly
        |-- julia-0.3
        |-- julia-0.4
        ...
    |-- share/
        |-- myproject
        |-- testing
        |-- research
    |-- src/
        |-- julia-038-osx10
            ...
    |-- tmp/
        |-- julia-0.3.8-osx10.7+.dmg
```

* bin: contains all the symlinks to installed julia versions (and also the playground script itself)
* share: contains all the named playgrounds or links to named playgrounds.
* src: contains the extracted binary builds and cloned julia repos.
* tmp: just contains the raw julia binary downloads


#### config.yml ####
The config.yml file provides a mechanism for configuring default behaviour. This file is setup during installation.

```
---
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: .playground

# Default shell prompt when you activate a playground.
default_prompt: "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m"

# Default git settings when using install build
default_git_address: "https://github.com/JuliaLang/julia.git"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
```

### TODOs ###
* Setup coveralls
* More thorough test coverage
* Full windows support including `install`
* `install build` support.
