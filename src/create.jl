function create(directory::AbstractString, julia::AbstractString,
    name::AbstractString, requirements::AbstractString, config::Config())

    if directory == "" && name != ""
        directory = joinpath(config.dir.store, name)
    elseif directory != "" && name != ""
        mklinke(abspath(directory), joinpath(config.dir.store, name))
    end

    root_path = abspath(directory)
    bin_path = joinpath(root_path, "bin")
    log_path = joinpath(root_path, "log")
    pkg_path = joinpath(root_path, "packages")
    julia_path = joinpath(bin_path, "julia")
    julia_src_path = joinpath(root_path, "julia_src")
    gitlog = joinpath(log_path, "git.log")

    mkpath(root_path)
    mkpath(bin_path)
    mkpath(log_path)
    mkpath(pkg_path)

    Logging.configure(level=DEBUG, filename=joinpath(log_path, "playground.log"))
    Logging.info("Playground folders created")

    if julia != ""
        mklink(joinpath(config.dir.bin, julia), julia_path)
    else
        mklink(readall(`which julia`), julia_path)
    end

    run(`$julia_path ie Pkg.init()`)

    if requirements != "" && ispath(requirements)
        if basename(requirements) == "REQUIRE"
            for pkg_subdir in readdir(pkg_path)
                if isdir(pkg_subdir)
                    copy(requirements, joinpath(pkg_path, pkg_subdir))
                    run(`$julia_path -e Pkg.resolve()`)
                end
            end
        elseif basename(requirements) == "DECLARE"
            # DeclarativePackages.jl seems a little awkwardly laid out
            # so I'll come back to this.
        end
    end
end
