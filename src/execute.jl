function execute(config::Config, cmd::Cmd; dir::AbstractPath=Path(), name::AbstractString="")
    init(config)
    pg = Environment(config, dir, name)
    set_envs(pg)

    run(cmd)
end
