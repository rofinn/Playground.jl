function create(config::Config; dir::AbstractString="", name::AbstractString="",
    julia::AbstractString="", reqs_file::AbstractString="", reqs_type::Symbol=:REQUIRE)

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
        if basename(reqs_file) == "DECLARE" || reqs_type == :DECLARE
            if ispath(DECLARATIVE_PACKAGES_DIR)
                ENV["DECLARE"] = reqs_file
                ENV["JULIA_PKGDIR"] = joinpath(pg.pkg_path, ".declare_packages")
                mkpath(ENV["JULIA_PKGDIR"])
                copy(reqs_file, joinpath(ENV["JULIA_PKGDIR"], "DECLARE"))

                old_folders = readdir(pg.pkg_path)
                info("Installing packages from DECLARE file $reqs_file...")
                passed = false
                try
                    run(`$(pg.julia_path) $(DECLARATIVE_PACKAGES_DIR)/src/installpackages.jl`)
                    passed = true
                catch
                    passed = false
                    warn("Failed to install from DECLARE file. Perhaps there is something wrong with your DECLARE file or you need to update DeclarativePackages.jl")
                end

                if passed
                    # Despite a declarative packages JULIA_PKGDIR being provided
                    # DeclarativePackages will just create a temporary folder
                    # in the parent directory. So we compare the pg.pkg_path before
                    # and after running installpackages.jl. Once, we find the generated folder
                    # that isn't just symlinks we copy the version folder over.
                    new_folders = readdir(pg.pkg_path)
                    to_delete = []
                    for f in new_folders
                        if !(f in old_folders)
                            declared_folder = joinpath(pg.pkg_path, f)
                            push!(to_delete, declared_folder)
                            if !islink(declared_folder) && isdir(declared_folder)
                                for v in readdir(declared_folder)
                                    vfolder = joinpath(declared_folder, v)
                                    copy(vfolder, joinpath(pg.pkg_path, v))
                                end
                            end
                        end
                    end
                    for d in to_delete
                        try
                            rm(d, recursive=true)
                        catch
                            @compat if is_unix()
                                run(`chmod -R 755 $d`)
                                run(`rm -rf $d`)
                            end
                        end
                    end
                end
            else
                warn("DeclarativePackages isn't installed")
            end
        elseif basename(reqs_file) == "REQUIRE" || reqs_type == :REQUIRE
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
            error("Unknown requirements file type $reqs_type for file $reqs_file")
        end
    else
        run(`$(pg.julia_path) -e Pkg.init()`)
    end
end
