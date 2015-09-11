function activate(config::Config; dir::AbstractString="", name::AbstractString="")
    init(config)

    pg = PlaygroundConfig(config, dir, name)
    set_envs(pg)

    prompt = config.default_prompt

    Logging.info("Executing a playground shell")
    if name != ""
        prompt = replace(prompt, "playground", name)
    else
        found = get_playground_name(config, pg.root_path)
        if found != ""
            prompt = replace(prompt, "playground", found)
        end
    end

    run_shell(prompt)
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
                    write(fstream, "export PS1=\"$(prompt)\"\n")
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
