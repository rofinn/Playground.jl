# TODO: Should really be named "Playground". If we do rename this type this file should be
# then named "playground.jl"

type PlaygroundConfig
    name::AbstractString
    root_path::AbstractString
    log_path::AbstractString
    bin_path::AbstractString
    pkg_path::AbstractString
    julia_path::AbstractString
    default_shell::AbstractString
    isolated_shell_history::Bool
    isolated_julia_history::Bool

    function PlaygroundConfig(config::Config, dir::AbstractString, name)
        root_path = get_playground_dir(config, dir, name)
        new(
            name,
            root_path,
            joinpath(root_path, "log"),
            joinpath(root_path, "bin"),
            joinpath(root_path, "packages"),
            joinpath(root_path, "bin", "julia"),
            config.default_shell,
            config.isolated_shell_history,
            config.isolated_julia_history
        )
    end
end

function create_paths(pg::PlaygroundConfig)
    mkpath(pg.root_path)
    mkpath(pg.bin_path)
    mkpath(pg.log_path)
    mkpath(pg.pkg_path)
end


function set_envs(pg::PlaygroundConfig)
    ENV["PATH"] = "$(pg.bin_path):" * ENV["PATH"]
    ENV["PLAYGROUND_ENV"] = pg.name == "" ? basename(pg.root_path) : pg.name
    ENV["JULIA_PKGDIR"] = pg.pkg_path

    if pg.default_shell != ""
        ENV["SHELL"] = pg.default_shell
    end

    if pg.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(pg.root_path, ".julia_history")
    end

    if pg.isolated_shell_history
        ENV["HISTFILE"] = joinpath(pg.root_path, ".shell_history")
    end
end
