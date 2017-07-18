# Executable

The primary interface provided by Playground.jl is via the `playground` executable,
which includes several subcommands for manipulating playground environments.

```shell
> playground -h
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

## install (Unix only)

To install a binary julia version from https://julialang-s3.julialang.org.
```shell
# playground install download <version> --labels label1 label2
playground install download 0.3 --labels julia-0.3
```

To make an existing build available to playgrounds.
```shell
# playground install link <path> --labels label1 label2
playground install link /path/to/julia/binary --labels julia-src
```

**[TODO]** To build and install a julia version from source.
```shell
playground install build --url https://github.com/MyUser/julia.git --rev dev --labels julia-wip
```
This is less of a priority as most individuals can just manually build from source and use `playground install link` to make their build available.
Similarly, this particular subcommand will be more brittle as it depends on the success of the julia build process.

NOTE: Along with the provided labels, all install cmds will automatically create symlinks for the full version and commit eg: `julia-0.3.11` and `julia-128797f`.


## create
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
playground create /path/of/new/playground --name nightly-playground --julia-version julia-nightly
```

To create a new playground with pre-existing requirements using REQUIRE or DECLARE files.
```shell
playground create --requirements /path/to/REQUIRE/or/DECLARE/file
```

If the basename of the file is not `REQUIRE` or `DECLARE` you can still specify the requirement type.
```shell
playground create --requirements /path/to/requirements/file --req-type DECLARE
```

If using DECLARE files you should make sure that `DeclarativePackages.jl` is already installed.


## activate
To activate a given playground simply run.
```shell
playground activate /path/to/your/playground
```
or
```shell
playground activate --name myproject
```

NOTE: On Unix systems, activate will try and open a new shell using you SHELL environment variable and a modified copy of your `~/.<shell>rc` file. Otherwise, it will fall back to using `sh -i`.


## list
To see what install julia-versions and playgrounds (named ones) are available.
```shell
playground list
```


## clear
If you've removed some a source julia-version or have deleted playground folders and would like playground to clean up any broken symlinks.
```shell
playground clean
```

## rm
If you'd like to remove a julia-version or playground you can run.
```shell
playground rm [playground-name|julia-version] --dir /path/to/playgrounds
```
which will delete the specified playground or julia-version and make sure that all related links have been cleaned up.
**Warning**: Deleting julia versions may break playgrounds that depend on that version. If this occurs you can either manually recreate the julia symlink with `ln -s ~/.playground/bin/<julia-version> /path/to/playground/bin/julia` or better yet recreate the playground.
