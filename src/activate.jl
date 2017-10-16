"""
    activate(; shell=true)
    activate(config::Config, args...; shell=true)
    activate(env::Environment; shell=true)

Modifies the current environment to operate within a specific playground environment.
When `shell=true` a new shell environment will be created.
However, when `shell=false` the existing julia REPL will be modifed and
`deactivate()` must be called to restore the REPL state.
"""
activate(; shell=true) = activate(Environment(); shell=shell)

function activate(config::Config, args...; shell=true)
    activate(Environment(config, args...); shell=shell)
end

function activate(env::Environment; shell=true)
    prompt = getprompt(env; shell=shell)
    debug(logger, "Activating playground $(name(env))...")

    if shell
        withenv(env) do
            runshell(prompt)
        end
    else
        old = Dict{Symbol, Any}()
        old[:ENV] = set!(env, getenvs(env)...)
        try
            old[:PROMPT] = input_prompt()
            input_prompt!(prompt, :magenta)
        catch e
            warn(logger, "Failed to set the julia prompt to $prompt ($e)")
        finally
            push!(cache, old)
        end
    end
end

"""
    deactivate()

Deactivates the active environment and restores the original julia environment.
"""
function deactivate()
    if !isempty(cache)
        debug(logger, "Deactivating playground ...")
        old = pop!(cache)

        try
            input_prompt!(old[:PROMPT])
        catch _
            warn(logger, string("Failed to restore the julia prompt."))
        end

        restore!(old[:ENV])
    else
        warn(logger, "There are no cached environment settings to restore.")
    end
end
