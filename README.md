Playground.jl
=============
[![Build Status](https://travis-ci.org/Rory-Finnegan/Playground.jl.svg)](https://travis-ci.org/Rory-Finnegan/Playground.jl)

A package for managing julia sandboxes like python's virtualenv.

### Installation ###
Install the julia package
```shell
julia>Pkg.add("Playground")
```
Running the playground script
```shell
~/.julia/v0.3/Playground/deps/usr/bin/playground
```
Optional: add the playground script to your path by editing your 
~/.bashrc, ~/.zshrc, ~/.tcshrc, etc.
```shell
echo "PATH=$PATH:~/.playground/bin/" >> ~/.bashrc
```


### Usage ###
#### Create ####
To create a new playground using your existing julia install.
```shell
playground /path/of/new/playground create
```
To create a new playground with a specific pre-built julia binary.
```shell
playground /path/of/new/playground create --julia /path/to/julia/executable
```
To create a new playground with a specific version of julia.
```shell
playground /path/of/new/playground create --julia v0.1
```
To create a new playground with a specific git revision of julia.
```shell
playground /path/of/new/playground create --julia 9effcb3
```
NOTES:
* The last two examples involve rebuilding julia from source and will take a long time.
* When creating a new playground you can pass a `--clean` which will delete any existing files in the playground directory if it is an existing playground.

#### Activate ####
To activate a given playground simply run.
```shell
playground /path/to/your/playground activate
```

### TODOs ###
* Tests
* untested on non-linux platforms!

### Configuration ###
By default Playground.jl creates its own config folder in `~/.playgournd`. This folder is structured as follows.
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

#### config.yml ####
The config.yml file provides a mechanism for configuring default behaviour. This file is setup during installation.

[Full description of options]
```
# This is just default location to store a new playground.
# This is used by create and activate if no --name or --path.
default_playground_path: ./.playground

# Default shell prompt when you activate a playground.
activated_prompt: "playground> "

# Default git settings when using install build
default_git_address: "https://github.com/JuliaLang/julia.git"
default_git_revision: master

# Allows you to isolate shell and julia history to each playground.
isolated_shell_history: true
isolated_julia_history: true
```

