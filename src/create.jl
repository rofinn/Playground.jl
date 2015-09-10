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

    ENV["JULIA_PKGDIR"] = pkg_path

    if reqs_file != "" && ispath(reqs_file)
        if basename(reqs_file) == "REQUIRE" || reqs_type == :REQUIRE
            for pkg_subdir in readdir(pkg_path)
                if isdir(pkg_subdir)
                    copy(reqs_file, joinpath(pkg_path, pkg_subdir))
                    run(`$julia_path -e Pkg.resolve()`)
                end
            end
        elseif basename(reqs_file) == "DECLARE" || reqs_type == :DECLARE
            dp_path = Pkg.dir("DeclarativePackages")
            pkg_dir = joinpath(Pkg.dir(), "REQUIRE")
            if ispath(dp_path)
                if !ispath(pkg_dir)
                    run(`DECLARE=$reqs_file $julia_path $dp_path/src/installpackages.jl`)
                else
                    Logging.warn("DeclarativePackages can only be run on fresh pkg directories.")
                end
            else
                Logging.warn("DeclarativePackages isn't installed")
            end
        end
    end

    if dir != "" && name != ""
        mklink(root_path, abspath(joinpath(config.dir.store, name)))
    end

    run(`$julia_path -e Pkg.init()`)
end
