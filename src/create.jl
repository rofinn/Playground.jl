function create(config::Config; dir::AbstractString="", name::AbstractString="",
    julia::AbstractString="", reqs_file::AbstractString="", reqs_type::Symbol=:REQUIRE)

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

    if dir != "" && name != ""
        mklink(root_path, abspath(joinpath(config.dir.store, name)))
    end

    ENV["JULIA_PKGDIR"] = pkg_path

    if reqs_file != "" && ispath(reqs_file)
        if basename(reqs_file) == "DECLARE" || reqs_type == :DECLARE
            if ispath(DECLARATIVE_PACKAGES_DIR)
                Logging.info("Installing packages from DECLARE file $reqs_file...")
                ENV["DECLARE"] = reqs_file
                ENV["JULIA_PKGDIR"] = joinpath(pkg_path, ".declare_packages")
                mkpath(ENV["JULIA_PKGDIR"])
                copy(reqs_file, joinpath(ENV["JULIA_PKGDIR"], "DECLARE"))

                old_folders = readdir(pkg_path)
                run(`$julia_path $(DECLARATIVE_PACKAGES_DIR)/src/installpackages.jl`)

                # Despite a declarative packages JULIA_PKGDIR being provided
                # DeclarativePackages will just create a temporary folder
                # in the parent directory. So we compare the pkg_path before
                # and after running installpackages.jl. Once, we find the generated folder
                # that isn't just symlinks we copy the version folder over.
                new_folders = readdir(pkg_path)
                to_delete = []
                for f in new_folders
                    if !(f in old_folders)
                        declared_folder = joinpath(pkg_path, f)
                        push!(to_delete, declared_folder)
                        if !islink(declared_folder) && isdir(declared_folder)
                            for v in readdir(declared_folder)
                                vfolder = joinpath(declared_folder, v)
                                copy(vfolder, joinpath(pkg_path, v))
                            end
                        end
                    end
                end
                for d in to_delete
                    try
                        rm(d, recursive=true)
                    catch
                        @unix_only begin
                            run(`chmod -R 755 $d`)
                            run(`rm -rf $d`)
                        end
                    end
                end
            else
                Logging.warn("DeclarativePackages isn't installed")
            end
        elseif basename(reqs_file) == "REQUIRE" || reqs_type == :REQUIRE
            Logging.info("Installing packages from REQUIRE file $reqs_file...")
            run(`$julia_path -e Pkg.init()`)
            for v in readdir(pkg_path)
                copy(reqs_file, joinpath(pkg_path, v, "REQUIRE"))
                run(`$julia_path -e Pkg.resolve()`)
            end
        else
            error("Unknown requirements file type $reqs_type for file $reqs_file")
        end
    else
        run(`$julia_path -e Pkg.init()`)
    end
end
