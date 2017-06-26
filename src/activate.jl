function activate(config::Config; dir::AbstractPath=Path(), name::AbstractString="")
    init(config)
    pg = Environment(config, dir, name)
    prompt = config.default_prompt

    if !isempty(name)
        prompt = replace(prompt, "playground", name)
    else
        found = get_playground_name(config, pg.root)
        if found != ""
            prompt = replace(prompt, "playground", found)
            pg.name = found
        end
    end

    set_envs(pg)
    run_shell(pg, prompt)
end


if is_windows()
    function run_shell(config, prompt)
        @mock run(`cmd /K prompt $(prompt)`)
    end
elseif is_unix()
    function run_shell(config, prompt)
        ENV["PS1"] = prompt
        if haskey(ENV, "SHELL") && contains(ENV["SHELL"], "fish")
            @mock run(`$(ENV["SHELL"]) -i`)
        elseif haskey(ENV, "SHELL")
            # Try and setup the new shell as close to the user's default shell as possible.
            usr_rc = join(home(), "." * basename(ENV["SHELL"] * "rc"))
            pg_rc = join(parent(Path(ENV["JULIA_PKGDIR"])), basename(ENV["SHELL"] * "rc"))

            if !exists(pg_rc)
                cp(usr_rc, pg_rc, follow_symlinks=true)
                content = string(
                    "export PATH=", ENV["PATH"], "\n",
                    "export PS1=\"$(prompt)\"\n",
                    "export JULIA_PKGDIR=", ENV["JULIA_PKGDIR"], "\n",
                )

                if haskey(ENV, "HISTFILE")
                    content = string(content, "export HISTFILE=", ENV["HISTFILE"], "\n")
                end

                write(pg_rc, content, "a")
            end

            if contains(ENV["SHELL"], "zsh")
    			@mock run(`$(ENV["SHELL"]) -c "source $pg_rc; $(ENV["SHELL"])"`)
    		else
    			@mock run(`$(ENV["SHELL"]) --rcfile $pg_rc`)
    		end
        else
            @mock run(`sh -i`)
        end
    end
end
