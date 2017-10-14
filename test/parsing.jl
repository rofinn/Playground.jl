
@testset "parsing" begin
    @testset "install" begin
        @testset "download" begin
            args = argparse(["install", "download", "0.3"])
            @test args == Dict(
                "%COMMAND%" => "install",
                "install" => Dict(
                    "%COMMAND%" => "download",
                    "download" => Dict(
                        "labels" => AbstractString[],
                        "version" => v"0.3",
                    )
                ),
                "debug" => false
            )
        end
        @testset "link" begin
            args = argparse(["install", "link", "/path/to/julia", "--labels", "julia-src"])
            @test args == Dict(
                "%COMMAND%" => "install",
                "install" => Dict(
                    "%COMMAND%" => "link",
                    "link" => Dict(
                        "labels" => AbstractString["julia-src"],
                        "dir" => p"/path/to/julia"
                    )
                ),
                "debug" => false
            )
        end
    end
    @testset "create" begin
        @testset "defaults" begin
            args = argparse(["create"])
            @test args == Dict(
                "%COMMAND%" => "create",
                "create" => Dict(
                    "dir" => Path(),
                    "requirements" => Path(),
                    "name" => "",
                    "julia-version" => "",
                    "julia-metadata" => "",
                    "julia-meta-branch" => "",
                ),
                "debug" => false
            )
        end
        @testset "arguments" begin
            args = argparse(
                [
                    "create", "/path/to/playground",
                    "--name", "myplayground",
                    "--julia-version", "julia-0.3",
                    "--requirements", "/path/to/requirements",
                    "--julia-metadata", "https://github.com/rofinn/Playground.jl",
                    "--julia-meta-branch", "playground",
                ]
            )
        end
    end

    @testset "activate" begin
        @testset "defaults" begin
            args = argparse(["activate"])
            @test args == Dict(
                "%COMMAND%" => "activate",
                "activate" => Dict(
                    "dir" => Path(),
                    "name" => ""
                ),
                "debug" => false
            )
        end
        @testset "arguments" begin
            args = argparse(["activate", "--name", "myplayground"])
            @test args == Dict(
                "%COMMAND%" => "activate",
                "activate" => Dict(
                    "dir" => Path(),
                    "name" => "myplayground"
                ),
                "debug" => false
            )
        end
    end

    @testset "exec" begin
        args = argparse(["exec", "ls -al", "--name", "myplayground"])
        @test args == Dict(
            "%COMMAND%" => "exec",
            "exec" => Dict(
                "cmd" => "ls -al",
                "dir" => Path(),
                "name" => "myplayground"
            ),
            "debug" => false
        )
    end

    @testset "list" begin
        args = argparse(["list", "--show-links"])
        @test args == Dict(
            "%COMMAND%" => "list",
            "list" => Dict(
                "show-links" => true
            ),
            "debug" => false
        )
    end

    @testset "clean" begin
        args = argparse(["clean"])
        @test args == Dict(
            "%COMMAND%" => "clean",
            "clean" => Dict(),
            "debug" => false
        )
    end

    @testset "remove" begin
        args = argparse(["rm", "myplayground"])
        @test args == Dict(
            "%COMMAND%" => "rm",
            "rm" => Dict(
                "dir" => Path(),
                "name" => "myplayground"
            ),
            "debug" => false
        )
    end
end
