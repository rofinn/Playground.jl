struct KSH <: AbstractShell
    path::AbstractString
    prompt::AbstractString
end

KSH(path::AbstractString) = KSH(path, "(playground)> ")
KSH() = KSH(strip(readstring(`which ksh`)))

function Base.run(shell::KSH, env::Environment)
    init(env)
    prompt = getprompt(shell, env)
    ENV["PS1"] = prompt

    usr_rc = join(Path(home()), ".kshrc")
    pg_rc = join(parent(Path(ENV["JULIA_PKGDIR"])), ".kshrc")

    if !exists(pg_rc)
        exists(usr_rc) ? cp(usr_rc, pg_rc, follow_symlinks=true) : touch(pg_rc)

        content = string(
            "\nexport PATH=\"", ENV["PATH"], "\"\n",
            "export PS1=\"$prompt\"\n",
            "export JULIA_PKGDIR=\"", ENV["JULIA_PKGDIR"], "\"\n",
        )

        if haskey(ENV, "HISTFILE")
            content = string(content, "export HISTFILE=\"", ENV["HISTFILE"], "\"\n")
        end

        write(pg_rc, content, "a")
    end

    ENV["ENV"] = pg_rc
    @mock run(`$(shell.path) -i`)
end