# Playground.jl

[![Build Status](https://travis-ci.org/rofinn/Playground.jl.svg)](https://travis-ci.org/rofinn/Playground.jl)
[![codecov.io](http://codecov.io/github/rofinn/Playground.jl/coverage.svg)](http://codecov.io/github/rofinn/Playground.jl)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

A package for managing julia sandboxes like python's virtualenv (with a little influence from pyenv and virtualenvwrapper)

**Supports**:
[![StatsBase](http://pkg.julialang.org/badges/Playground_0.5.svg)](http://pkg.julialang.org/?pkg=Playground&ver=0.5)
[![StatsBase](http://pkg.julialang.org/badges/Playground_0.6.svg)](http://pkg.julialang.org/?pkg=Playground&ver=0.6)

## Installation

You can install Playground.jl with `Pkg.add`.

```julia
julia> Pkg.add("Playground")
```

If you'd like to install the `playground` script and `config.yml` file to the shared
`~/.playground` directory run:

```julia
julia> ENV["PLAYGROUND_INSTALL"] = true; Pkg.build("Playground")
```

The playground script is now ready to use.
```shell
> ~/.playground/bin/playground -h
usage: <PROGRAM> [-d] [-h]
                 {install|create|activate|list|clean|rm|exec}

commands:
  install      Installs julia version for you.
  create       Builds the playground
  activate     Activates the playground.
  list         Lists available julia versions and playgrounds
  clean        Deletes any dead julia-version or playground links, in
               case you've deleted the original folders.
  rm           Deletes the specifid julia-version or playground.
  exec         Execute a cmd inside a playground and exit.

optional arguments:
  -d, --debug  Log debug message to STDOUT
  -h, --help   show this help message and exit
```

**Recommended:** Add the playground bin directory to your path
by editing your ~/.bashrc, ~/.zshrc, ~/.tcshrc, etc.
```shell
echo "PATH=~/.playground/bin/:$PATH" >> ~/.bashrc
```
This will make the playground script and all managed julia versions easily accessible.

**NOTE:** Currently, some of the dependencies in Playground.jl such as Options.jl and ArgParse.jl throw deprecation warnings. If you'd like to ignore these warnings until new versions of these packages are release just add `--depwarn=no` to the shebang in `~/.playground/bin/playground`. If you're running linux you'll need to change this line to `#!/usr/bin/julia --depwarn=no` as `env` in linux can only take 1 argument otherwise the process will stall.

## Overview

## Configuration ##
For the most part, Playground.jl provide its virtualized environments by simply manipulating environment variables and symlinks to julia binaries/playgrounds. However, in order to do this it needs to create its own folder for managing these symlinks. By default Playground.jl creates its own config folder in `~/.playground`. This folder is structured as follows.
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


### config.yml ###
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


## TODOs ##
* More thorough test coverage
* Full windows support including `install`
* `install build` support.
