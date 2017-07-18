"""
    execute(f::Union{Function, Cmd})
    execute(f::Union{Function, Cmd}, env::Environment)
    execute(f::Union{Function, Cmd}, config::Config, args...)

Runs the function or command inside a playground.
"""
execute(f::Function, env::Environment) = withenv(f, env)
execute(f::Function) = execute(f, Environment())
execute(f::Function, config::Config, args...) = execute(f, Environment(config, args...))

function execute(cmd::Cmd, args...)
    execute(args...) do
        debug(logger, "Executing $cmd...")
        run(cmd)
    end
end
