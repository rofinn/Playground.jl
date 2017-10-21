struct BASH <: AbstractShell
    path::AbstractString
    prompt::AbstractString
end

BASH(path::AbstractString) = BASH(path, "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m")
BASH() = BASH(strip(readstring(`which bash`)))

function Base.run(shell::BASH, env::Environment)
    prompt = getprompt(shell, env)
    ENV["PS1"] = prompt

    usr_rc = join(Path(get(ENV, "ZDOTDIR", home())), ".bashrc")
    pg_rc = join(parent(Path(ENV["JULIA_PKGDIR"])), ".bashrc")

    if !exists(pg_rc)
        exists(usr_rc) ? cp(usr_rc, pg_rc, follow_symlinks=true) : touch(pg_rc)

        content = string(
            "\nexport PATH=", ENV["PATH"], "\n",
            "export PS1=\"$prompt\"\n",
            "export JULIA_PKGDIR=", ENV["JULIA_PKGDIR"], "\n",
        )

        if haskey(ENV, "HISTFILE")
            content = string(content, "export HISTFILE=", ENV["HISTFILE"], "\n")
        end

        write(pg_rc, content, "a")
    end

    @mock run(`$(shell.path) --rcfile $pg_rc -i`)
end