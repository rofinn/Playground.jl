create(; kwargs...) = create(Environment(); kwargs...)
create(config::Config, args...; kwargs...) = create(Environment(config, args...); kwargs...)

function create(env::Environment; kwargs...)
    init(env)
    opts = Dict(kwargs)

    julia_exec = if haskey(opts, :julia) && !isempty(opts[:julia])
        join(env.config.bin, opts[:julia])
    else
        out = readchomp(`which julia`)
        debug(logger, out)
        debug(logger, Path(out))
        debug(logger, abs(Path(out)))
        abs(Path(readchomp(`which julia`)))
    end

    debug(logger, "$(julia(env)) -> $julia_exec")
    symlink(julia_exec, julia(env), exist_ok=true, overwrite=true)

    withenv(env) do
        if haskey(opts, :reqs_file) && !isempty(opts[:reqs_file]) && exists(opts[:reqs_file])
            info(logger, "Installing packages from REQUIRE file $(opts[:reqs_file])...")
            Playground.log_output(`$(julia(env)) -e 'Pkg.init()'`)
            for v in readdir(pkg(env))
                copy(opts[:reqs_file], join(pkg(env), v, "REQUIRE"); exist_ok=true, overwrite=true)
                try
                    Playground.log_output(`$(julia(env)) -e 'Pkg.resolve()'`)
                catch
                    warn(logger, string(
                        "Failed to resolve requirements. ",
                        "Perhaps there is something wrong with your REQUIRE file."
                    ))
                end
            end
        else
            Playground.log_output(`$(julia(env)) -e 'Pkg.init()'`)
        end
    end
end
