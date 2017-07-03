"""
    activate(; shell=true)
    activate(config::Config, args...; shell=true)
    activate(env::Environment; shell=true)

Modifies the current environment to operate within a specific playground environment.
When `shell=true` a new shell environment will be created.
However, when `shell=false` the existing julia REPL will be modifed and
`deactive(env::Enviornmentt)` must be called to restore the REPL state.
"""
activate(; shell=true) = activate(Environment(); shell=shell)

function activate(config::Config, args...; shell=true)
    println(args)
    activate(Environment(config, args...); shell=shell)
end

function activate(env::Environment; shell=true)
    prompt = getprompt(env; shell=shell)
    debug(logger, "Activating playground $prompt...")

    if shell
        withenv(env) do
            runshell(prompt)
        end
    else
        env.active = true
        set!(env, getenvs(env)...)
        try
            env.cache["prompt"] = strip(Base.active_repl.interface.modes[1].prompt)
            input_prompt!(prompt, :magenta)
        catch e
            warn(logger, "Failed to set the julia prompt to $prompt ($e)")
        end
    end
    return env
end

"""
    deactivate(env::Environment)

Deactivates the active environment and restores the original julia environment.
"""
function deactivate(env::Environment)
    if env.active
        debug(logger, "Deactivating playground $(name(env))...")

        try
            input_prompt!(env.cache["prompt"])
        catch _
            warn(logger, string("Failed to restore the julia prompt."))
        end
        restore!(env)
        env.active=false
    else
        warn(logger, "Environment $env is not active.")
    end
    return env
end
