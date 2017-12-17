abstract type AbstractShell <: AbstractREPL end

include("shells/bash.jl")
include("shells/zsh.jl")
include("shells/ksh.jl")
include("shells/fish.jl")
include("shells/cmdexe.jl")

function getshell(shell="/bin/bash")
    function findshell(sh)
        if contains(sh, "bash")
            return BASH(sh)
        elseif contains(sh, "zsh")
            return ZSH(sh)
        elseif contains(sh, "fish")
            return FISH(sh)
        elseif contains(sh, "ksh")
            return KSH(sh)
        else
            warn(logger, "SHELL $sh not supported.")
            return nothing
        end
    end

    if haskey(ENV, "SHELL")
        sh = findshell(ENV["SHELL"])

        if sh === nothing
            return findshell(shell)
        else
            return sh
        end
    elseif is_windows()
        return CmdExe()
    elseif is_unix()
        return findshell(shell)
    end
end
