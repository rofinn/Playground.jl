abstract type AbstractShell <: AbstractREPL end

function runsh(cmd::Cmd)
    # If we're in the situation where we want to mock the call, but mocking hasn't been enabled
    # then we want to produce a warning and skip that run call. Otherwise we can just run the call as
    # it'll be correctly mocked or we want to execute the command.
    if Mocking.ENABLED
        warn(logger, "Mocking is enabled, but precompilation has not been disabled.")
        warn(logger, "Skipping interactive shell execution: $cmd")
        idx = find(x -> x == "-i", cmd.exec)[1]
        cmd_exec = cmd.exec[1:idx-1]
        append!(cmd_exec, ["-c", "echo \"Hello World!\""])
        return readstring(Cmd(cmd_exec))
    else
        return run(cmd)
    end
end

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
