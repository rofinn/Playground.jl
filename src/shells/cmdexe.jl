struct CmdExe <: AbstractShell
    prompt::AbstractString
end

CmdExe() = new("playground>")

function Base.run(shell::CmdExe, env::Environment)
    prompt = getprompt(shell, env)
    run(`cmd /K prompt $prompt`)
end