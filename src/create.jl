function create(
    config::Config;
    dir::AbstractString="",
    name::AbstractString="",
    julia::AbstractString="",
    reqs_file::AbstractString=""
)

    init(config)
    pg = Environment(config, dir, name)
    init(pg)
    info("Playground folders created")

    if julia != ""
        mklink(joinpath(config.bin, julia), pg.julia)
    else
        sys_julia = abspath(readchomp(`which julia`))
        mklink(sys_julia, pg.julia)
    end

    if dir != "" && name != ""
        mklink(pg.root, abspath(joinpath(config.share, name)))
    end

    ENV["JULIA_PKGDIR"] = pg.pkg

    if reqs_file != "" && ispath(reqs_file)
        info("Installing packages from REQUIRE file $reqs_file...")
        run(`$(pg.julia) -e 'Pkg.init()'`)
        for v in readdir(pg.pkg)
            copy(reqs_file, joinpath(pg.pkg, v, "REQUIRE"))
            try
                run(`$(pg.julia) -e 'Pkg.resolve()'`)
            catch
                warn("Failed to resolve requirements. Perhaps there is something wrong with your REQUIRE file.")
            end
        end
    else
        run(`$(pg.julia) -e 'Pkg.init()'`)
    end
end
