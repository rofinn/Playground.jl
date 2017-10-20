import Playground: BASH, ZSH, KSH, FISH

function test_run(cmd::Base.AbstractCmd)
    idx = find(x -> x == "-i", cmd.exec)[1]
    cmd_exec = cmd.exec[1:idx-1]
    append!(cmd_exec, ["-c", "echo \"Hello World!\""])
    return readstring(Cmd(cmd_exec))
end

@testset "shell" begin
    @testset "$SH" for SH in (BASH, ZSH, KSH, FISH)
        patch = @patch run(cmd::Base.AbstractCmd, args...) = test_run(cmd)

        Mocking.apply(patch) do
            sh = SH()
            resp = strip(run(sh, Environment("myproject")))
            @test resp == "Hello World!"
        end
    end
end