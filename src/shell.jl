abstract type AbstractShell <: AbstractREPL end

include("shells/bash.jl")
include("shells/zsh.jl")
include("shells/ksh.jl")
include("shells/fish.jl")
include("shells/cmdexe.jl")

function getshell()
    if haskey(ENV, "SHELL")
        sh = ENV["SHELL"]
        if contains(sh, "bash")
            return BASH(sh)
        elseif contains(sh, "zsh")
            return ZSH(sh)
        elseif contains(sh, "fish")
            return FISH(sh)
        elseif contains(sh, "ksh")
            return KSH(sh)
        else
            error(logger, "SHELL $sh not supported.")
        end
    elseif is_windows()
        return CmdExe()
    end
end
