# Binary Releases

As of v0.0.6 and up binary releases of playground are available for download [here](https://github.com/rofinn/Playground.jl/releases), which will allow you to run playground without having an existing julia install.

## Installing

1. Download the tar.gz file for your platform into your desired install location (ie: `~/bin`)
1. Go to that directory (`cd ~/bin`)
1. Extract the build (`tar -xvzf ~/bin/playground-osx.tar.gz`)
1. `cd playground && ./INSTALL.sh`
1. Create an alias that sets the `LD_LIBRARY_PATH` and calls the script. This should be placed in your shell rc file, so if your default shell is bash then you'd add `alias playground="LD_LIBRARY_PATH=~/bin/playground ~/bin/playground/playground"` to your `~/.bashrc` file.

**NOTE:** This alias hack with `LD_LIBRARY_PATH` is only necessary due to an issue in the binaries created with [BuildExecutable.jl](https://github.com/dhoegh/BuildExecutable.jl).
In future releases it should only be necessary for `~/bin/playground` to be on your search path (ie: in your `PATH` variable).

## Building

If you'd like to build you own playground binary executables you'll have a few more steps.
First, add `BuildExecutable` and checkout the current master.

```julia
julia> Pkg.add("BuildExecutable")

julia> Pkg.checkout("BuildExecutable.jl")
```

In order to tell the Playground.jl build script to create a binary executable you'll need to run
```julia
julia> ENV["PLAYGROUND_BIN_EXEC"] = true
```
prior to calling `Pkg.build("Playground")`.
