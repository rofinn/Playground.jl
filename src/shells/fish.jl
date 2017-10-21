struct FISH <: AbstractShell
    path::AbstractString
    prompt::AbstractString
end

FISH(path::AbstractString) = FISH(path, "\\e[0;35m\\u@\\h:\\W (playground)> \\e[m")
FISH() = FISH(strip(readstring(`which fish`)))

function Base.run(shell::FISH, env::Environment)
    # Currently can't support sourcing a custom fish prompt on startup until
    # 2.7.0 is released with the `-C` flag.
    # https://github.com/fish-shell/fish-shell/milestone/17
    @mock run(`$(shell.path) -i`)
end