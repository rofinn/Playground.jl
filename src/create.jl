function create(
    config::Config;
    dir::AbstractPath=Path(),
    name::AbstractString="",
    julia::AbstractString="",
    reqs_file::AbstractPath=Path()
)
    init(config)
    pg = Environment(config, dir, name)
    init(pg)
    info("Playground folders created")

    if julia != ""
        symlink(join(config.bin, julia), pg.julia, exist_ok=true, overwrite=true)
    else
        sys_julia = abs(Path(readchomp(`which julia`)))
        symlink(sys_julia, pg.julia, exist_ok=true, overwrite=true)
    end

    if !isempty(dir) && name != ""
        symlink(pg.root, abs(join(config.share, name)), exist_ok=true, overwrite=true)
    end

    ENV["JULIA_PKGDIR"] = pg.pkg

    if !isempty(reqs_file) && exists(reqs_file)
        info("Installing packages from REQUIRE file $reqs_file...")
        run(`$(pg.julia) -e 'Pkg.init()'`)
        for v in readdir(pg.pkg)
            copy(reqs_file, join(pg.pkg, v, "REQUIRE"); exist_ok=true, overwrite=true)
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
