import Playground: BASH, ZSH, KSH, FISH

function noninteractive_run(cmd::Cmd)
    if "-i" in cmd.exec
        warn(Playground.logger, "Skipping interactive shell execution: $cmd")
        idx = find(x -> x == "-i", cmd.exec)[1]
        cmd_exec = cmd.exec[1:idx-1]
        append!(cmd_exec, ["-c", "echo \"Hello World!\""])
        new_cmd = Cmd(cmd_exec)
        debug(Playground.logger, "Testing shell execution with $new_cmd")
        return readstring(Cmd(cmd_exec))
    else
        return run(cmd)
    end
end

@testset "shell" begin
    @testset "$SH" for SH in ("bash", "zsh", "ksh", "fish")
        if success(`which $SH`)
            path = readstring(`which $SH`)

            withenv("SHELL" => path) do
                sh = Playground.getshell()
                t = typeof(sh)
                @test endswith(lowercase("$t"), SH)
            end
        else
            warn("$SH not installed.")
        end
    end

    env = Environment(TEST_CONFIG, "myproject")

    @testset "$SH" for SH in (BASH, ZSH, KSH, FISH)
        patch = @patch run(cmd::Base.AbstractCmd, args...) = noninteractive_run(cmd)

        Mocking.apply(patch) do
            withenv(env) do
                name = split(lowercase(string(SH.name)), '.')[end]

                if success(`which $name`)
                    sh = SH()
                    try
                        resp = strip(run(sh, env))
                        @test resp == "Hello World!"
                    catch e
                        error(Playground.logger, e)
                    end
                else
                    warn(Playground.logger, "$name not installed.")
                end
            end
        end
    end
end