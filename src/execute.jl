import Base: run, readall, readchomp, chomp!

function run(pg::PlaygroundConfig, cmd::Cmd)
    withenv(pg) do
        run(cmd)
    end
end

function readall(pg::PlaygroundConfig, cmd::Cmd)
    withenv(pg) do
        readall(cmd)
    end
end

readchomp(pg::PlaygroundConfig, cmd::Cmd) = chomp!(readall(pg, cmd))
