# REPL

All of the functionality provided by the `playground` executable can be accessed
with the exported API.

**NOTES:**
* This API is still under development and while the functionality is largely
stable the exactly interface is still subject to change.
*  Playground differentiates `String`s and `Path`s using the `AbstractPath` type provided
by [FilePaths.jl](https://github.com/rofinn/FilePaths.jl). A path type can be created with `p"/path/to/my/thing"`.
* Memento logging can be configured for debugging purposes.
```julia
julia> using Memento

julia> Memento.config("debug")
```

## Config

Stores information about the shared configuration directory.
The easiest way to get a `Config` instances is with:

```julia
julia> config = Config()    # Uses the default config at ~/.playground/config.yml
```

## Environment

Methods that only operate on playground environments (e.g., `create`, `activate`) can also take an `Environment` type.
In future releases, the `Environment` type may be abstracted into an interface that supports different methods of isolation (e.g., `DockerEnvironment` for maintaining julia docker environments).

Example)

```julia
julia> env = Environment("research")    # A shared environment named "research"

# Create the research environment
julia> create(env)

# Activate the research environment in our current REPL
julia> activate(env; shell=false)

research> Pkg.dir()
"/Users/rory/.playground/share/research/packages/v0.6"

research> deactivate()

julia> Pkg.dir()
"/Users/rory/.julia/v0.6"

julia> withenv(env) do
           Pkg.dir()
       end
"/Users/rory/.playground/share/research/packages/v0.6"
```

## install (Unix only)

To install a binary julia version from http://julialang.org/downloads/.
```julia
julia> install(config, v"0.7.0-"; labels=["julia-0.7"])
```

To make an existing build available to playgrounds.
```julia
julia> install(config, p"/path/to/julia/binary"; labels=["julia-src"])
```

## create
To create a new playground using your existing julia install in your current working directory.
```julia
julia> create()
```

This will automatically create a `.playground` folder (default specified in `~/.playground/config.yml`)

To create a new playground in a specific directory.

```julia
julia> create(config, p"/path/of/new/playground")
```

To name your playgrounds and make them available without remembering where they're stored.
```julia
julia> create(config, "research-playground")
```

Create a playground with a default julia-version.
```julia
julia> create(config, p"/path/of/new/playground", "nightly-playground"; julia="julia-nightly")
```

Create a new playground with pre-existing REQUIRE file.
```julia
julia> create(; p"/path/to/REQUIRE")
```

## activate

To activate a given playground simply run.
```julia
julia> activate(config, p"/path/to/your/playground")
```
or
```julia
julia> activate(config, "myproject")
```

**NOTE:** On Unix systems, activate will by default try and open a new shell using you SHELL environment variable and a modified copy of your `~/.<shell>rc` file. Otherwise, it will fall back to using `sh -i`.

If you'd like to work within a playground environment from your current REPL just pass `shell=false`.

```julia
julia> activate(config, "myproject"; shell=false)
```

## list
To see what install julia-versions and playgrounds (named ones) are available.
```julia
julia> list(config)
```

## clear
If you've removed some a source julia-version or have deleted playground folders and would like playground to clean up any broken symlinks.
```julia
julia> clean(config)
```

## rm
If you'd like to remove a julia-version or playground you can run.
```julia
julia> rm(config, "myproject")
```
or
```julia
julia> rm(config, "julia-0.7")
```

which will delete the specified playground or julia-version and make sure that all related links have been cleaned up.

**Reminder:** Deleting julia versions may break playgrounds that depend on that version.
