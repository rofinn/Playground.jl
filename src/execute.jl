function execute(config::Config, cmd::Cmd; dir::AbstractString="", name::AbstractString="")
    init(config)

    pg = PlaygroundConfig(config, dir, name)
    set_envs(pg)

    run(cmd)
end
