function activate(config::Config; dir::AbstractString="", name::AbstractString="")
    init(config)

    pg = PlaygroundConfig(config, dir, name)

    prompt = config.default_prompt

    if name != ""
        prompt = replace(prompt, "playground", name)
    else
        found = get_playground_name(config, pg.root_path)
        if found != ""
            prompt = replace(prompt, "playground", found)
            pg.name = found
        end
    end

    set_envs(pg)
    run_shell(pg, prompt)
end


@windows_only function run_shell(config, prompt)
    run(`cmd /K prompt $(prompt)`)
end


@unix_only function run_shell(config, prompt)
    ENV["PS1"] = prompt
    if haskey(ENV, "SHELL") && contains(ENV["SHELL"], "fish")
        run(`$(ENV["SHELL"]) -i`)
    elseif haskey(ENV, "SHELL")
        # Try and setup the new shell as close to the user's default shell as possible.
        usr_rc = joinpath(homedir(), "." * basename(ENV["SHELL"]) * "rc")
        pg_rc = joinpath(dirname(ENV["JULIA_PKGDIR"]), basename(ENV["SHELL"]) * "rc")

        if !ispath(pg_rc)
            cp(usr_rc, pg_rc, follow_symlinks=true)
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
