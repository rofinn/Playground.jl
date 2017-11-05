struct ZSH <: AbstractShell
    path::AbstractString
    prompt::AbstractString
end

ZSH(path::AbstractString) = ZSH(path, "%F{5}%n@%m:%~ (playground)> %f")
ZSH() = ZSH(strip(readstring(`which zsh`)))

function Base.run(shell::ZSH, env::Environment)
    init(env)
    prompt = getprompt(shell, env)
    ENV["PS1"] = prompt

    debug(logger, "Shell prompt: $prompt")

    usr_rc = join(Path(get(ENV, "ZDOTDIR", home())), ".zshrc")
    pg_rc = join(parent(Path(ENV["JULIA_PKGDIR"])), ".zshrc")

    if !exists(pg_rc)
        debug(logger, "Creating shell rc file $pg_rc...")
        exists(usr_rc) ? cp(usr_rc, pg_rc, follow_symlinks=true) : touch(pg_rc)

        content = string(
            "\nunset PROMPT\n",
            "export PATH=", ENV["PATH"], "\n",
            "export PS1=\"$prompt\"\n",
            "export JULIA_PKGDIR=", ENV["JULIA_PKGDIR"], "\n",
        )

        if haskey(ENV, "HISTFILE") && exists(Path(ENV["HISTFILE"]))
            content = string(content, "export HISTFILE=", ENV["HISTFILE"], "\n")
        end

        debug(logger, "Writing rc contents to file.")
        write(pg_rc, content, "a")
    end

    ENV["ZDOTDIR"] = parent(pg_rc)
    runsh(`$(shell.path) -i`)
end