if is_windows()
    function runshell(prompt::AbstractString)
        @mock run(`cmd /K prompt $(prompt)`)
    end
elseif is_unix()
    function runshell(prompt::AbstractString)
        ENV["PS1"] = prompt
        if haskey(ENV, "SHELL") && contains(ENV["SHELL"], "fish")
            @mock run(`$(ENV["SHELL"]) -i`)
        elseif haskey(ENV, "SHELL")
            # Try and setup the new shell as close to the user's default shell as possible.
            usr_rc, pg_rc = begin
                if contains(ENV["SHELL"], "zsh")
                    usr = join(Path(get(ENV, "ZDOTDIR", home())), ".zshrc")
                    pg = join(parent(Path(ENV["JULIA_PKGDIR"])), ".zshrc")
                else
                    fname = basename(ENV["SHELL"]) * "rc"
                    usr = join(home(), "." * fname)
                    pg = join(parent(Path(ENV["JULIA_PKGDIR"])), fname)
                end
                usr, pg
            end

            if !exists(pg_rc)
                cp(usr_rc, pg_rc, follow_symlinks=true)
                content = string(
                    "export PATH=", ENV["PATH"], "\n",
                    "export PS1=\"$prompt\"\n",
                    "export JULIA_PKGDIR=", ENV["JULIA_PKGDIR"], "\n",
                )

                if contains(ENV["SHELL"], "zsh")
                    content = "unset PROMPT\n" * content  # Use the new PS1 instead.
                end

                if haskey(ENV, "HISTFILE")
                    content = string(content, "export HISTFILE=", ENV["HISTFILE"], "\n")
                end

                write(pg_rc, content, "a")
            end

            if contains(ENV["SHELL"], "zsh")
                ENV["ZDOTDIR"] = parent(pg_rc)
                @mock run(`$(ENV["SHELL"])`)
            else
                @mock run(`$(ENV["SHELL"]) --rcfile $pg_rc`)
            end
        else
            @mock run(`sh -i`)
        end
    end
end
