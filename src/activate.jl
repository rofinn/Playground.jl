function activate(config::Config; dir::AbstractString="", name::AbstractString="")
    init(config)

    root_path = get_playground_dir(config, dir, name)
    log_path = joinpath(root_path, "log")
    bin_path = joinpath(root_path, "bin")
    pkg_path = joinpath(root_path, "packages")

    Logging.configure(level=Logging.DEBUG, filename=joinpath(log_path, "playground.log"))

    Logging.info("Setting PATH variable to using to look in playground bin dir first")
    ENV["PATH"] = "$(bin_path):" * ENV["PATH"]
    Logging.info("Setting the JULIA_PKGDIR variable to using the playground packages dir")
    ENV["JULIA_PKGDIR"] = pkg_path

    if config.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(root_path, ".julia_history")
    end

    if config.isolated_shell_history
        ENV["HISTFILE"] = joinpath(root_path, ".shell_history")
    end

    Logging.info("Executing a playground shell")
    for p in readdir(config.dir.store)
        file_path = joinpath(config.dir.store, p)
        if islink(file_path)
            if abspath(readlink(file_path)) == root_path
                name = p
                break
            end
        end
    end

    prompt = config.default_prompt
    if name != ""
        prompt = replace(prompt, "playground", name)
    end
    run_shell(config.default_prompt)
end


@windows_only begin
    function run_shell(prompt)
        run(`cmd /K prompt $(prompt)`)
    end
end


@unix_only begin
    function run_shell(prompt)
        ENV["PS1"] = prompt
        if haskey(ENV, "SHELL")
            # Try and setup the new shell as close to the user's default shell as possible.
            usr_rc = joinpath(homedir(), "." * basename(ENV["SHELL"]) * "rc")
            pg_rc = joinpath(dirname(ENV["JULIA_PKGDIR"]), basename(ENV["SHELL"]) * "rc")

            if !ispath(pg_rc)
                cp(usr_rc, pg_rc)
                fstream = open(pg_rc, "a")
                try
                    path = ENV["PATH"]
                    ps1 = ENV["PS1"]
                    pkg_dir = ENV["JULIA_PKGDIR"]

                    write(fstream, "export PATH=$path\n")
                    write(fstream, "export PS1=\"$(ps1)\"\n")
                    write(fstream, "export JULIA_PKGDIR=$pkg_dir\n")

                    if haskey(ENV, "HISTFILE")
                        histfile = ENV["HISTFILE"]
                        write(fstream, "export HISTFILE=$histfile\n")
                    end
                finally
                    close(fstream)
                end
            end

            run(`$(ENV["SHELL"]) --rcfile $pg_rc`)
        else
            run(`sh -i`)
        end
    end
end
