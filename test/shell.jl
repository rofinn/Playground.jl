import Playground: BASH, ZSH, KSH, FISH

function test_run(cmd::Base.AbstractCmd)
    idx = find(x -> x == "-i", cmd.exec)[1]
    cmd_exec = cmd.exec[1:idx-1]
    append!(cmd_exec, ["-c", "echo \"Hello World!\""])
    # println(cmd_exec)
    return readstring(Cmd(cmd_exec))
end

@testset "shell" begin
    @testset "$SH" for SH in ("bash", "zsh", "ksh", "fish")
        rc = spawn(`which $SH`).exitcode

        if success(spawn(`which $SH`))
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
        patch = @patch run(cmd::Base.AbstractCmd, args...) = test_run(cmd)

        Mocking.apply(patch) do
            withenv(env) do
                name = lowercase(string(SH.name))
                rc = spawn(`which $name`).exitcode

                if success(spawn(`which $SH`))
                    sh = SH()
                    resp = strip(run(sh, env))
                    @test resp == "Hello World!"
                else
                    warn("$name not installed.")
                end
            end
        end
    end
end