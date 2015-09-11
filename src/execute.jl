function execute(config::Config, cmd::Cmd; dir::AbstractString="", name::AbstractString="")
    init(config)

    pg = PlaygroundConfig(config, dir, name)
    set_envs(pg)

    println("executing $cmd")
    run(cmd)
end
