function create(config::Config; dir::AbstractString="", name::AbstractString="",
    julia::AbstractString="", reqs::AbstractString="")

    init(config)

    root_path = get_playground_dir(config, dir, name)
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

    Logging.configure(level=Logging.DEBUG, filename=joinpath(log_path, "playground.log"))
    Logging.info("Playground folders created")

    if julia != ""
        mklink(joinpath(config.dir.bin, julia), julia_path)
    else
        sys_julia_path = abspath(strip(readall(`which julia`), '\n'))
        mklink(sys_julia_path, julia_path)
    end

    run(`$julia_path -e Pkg.init()`)

    if reqs != "" && ispath(reqs)
        if basename(reqs) == "REQUIRE"
            for pkg_subdir in readdir(pkg_path)
                if isdir(pkg_subdir)
                    copy(reqs, joinpath(pkg_path, pkg_subdir))
                    run(`$julia_path -e Pkg.resolve()`)
                end
            end
        elseif basename(reqs) == "DECLARE"
            Logging.warn("DECLARE files aren't supported yet")
            # DeclarativePackages.jl seems a little awkwardly laid out
            # so I'll come back to this.
        end
    end

    if dir != "" && name != ""
        mklink(root_path, abspath(joinpath(config.dir.store, name)))
    end
end
