function create(config::Config; dir::AbstractString="", name::AbstractString="",
    julia::AbstractString="", reqs_file::AbstractString="")

    init(config)

    pg = PlaygroundConfig(config, dir, name)
    create_paths(pg)

    info("Playground folders created")

    if julia != ""
        mklink(joinpath(config.dir.bin, julia), pg.julia_path)
    else
        sys_julia_path = abspath(readchomp(`which julia`))
        mklink(sys_julia_path, pg.julia_path)
    end

    if dir != "" && name != ""
        mklink(pg.root_path, abspath(joinpath(config.dir.store, name)))
    end

    ENV["JULIA_PKGDIR"] = pg.pkg_path

    if reqs_file != "" && ispath(reqs_file)
        info("Installing packages from REQUIRE file $reqs_file...")
        run(`$(pg.julia_path) -e Pkg.init()`)
        for v in readdir(pg.pkg_path)
            copy(reqs_file, joinpath(pg.pkg_path, v, "REQUIRE"))
            try
                run(`$(pg.julia_path) -e Pkg.resolve()`)
            catch
                warn("Failed to resolve requirements. Perhaps there is something wrong with your REQUIRE file.")
            end
        end
    else
        run(`$(pg.julia_path) -e Pkg.init()`)
    end
end
