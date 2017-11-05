import Playground: BASH, ZSH, KSH, FISH

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
                warn("$name not installed.")
            end
        end
    end
end