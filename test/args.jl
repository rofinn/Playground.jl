let args = Playground.argparse(["install", "download", "0.3"])
    @test args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "download",
            "download" => Dict(
                "version" => v"0.3",
                "labels" => AbstractString[],
            )
        )
    )
end

let args = Playground.argparse(["install", "link", "/path/to/julia", "--labels", "julia-src"])
    @test args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "link",
            "link" => Dict(
                "exec" => "/path/to/julia",
                "labels" => AbstractString["julia-src"],
            )
        )
    )
end

let args = Playground.argparse(["create"])
    @test args == Dict(
        "%COMMAND%" => "create",
        "create" => Dict{AbstractString,Any}(
            "name" => "",
            "dir" => "",
            "julia-version" => "",
            "requirements" => "",
            "req-type" => :REQUIRE,
        )
    )
end

let args = Playground.argparse(["create", "./myplayground"])
    @test args == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "name" => "",
            "dir" => "./myplayground",
            "julia-version" => "",
            "requirements" => "",
            "req-type" => :REQUIRE,
        )
    )
end

let args = Playground.argparse(["create", "myplayground"])
    @test args == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "name" => "myplayground",
            "dir" => "",
            "julia-version" => "",
            "requirements" => "",
            "req-type" => :REQUIRE,
        )
    )
end

let args = Playground.argparse([
        "create", "myplayground", "/path/to/playground",
        "--julia-version", "julia-0.3",
        "--requirements", "/path/to/requirements",
        "--req-type", "DECLARE",
    ])

    @test args == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "name" => "myplayground",
            "dir" => "/path/to/playground",
            "julia-version" => "julia-0.3",
            "requirements" => "/path/to/requirements",
            "req-type" => :DECLARE,
        )
    )
end

let args = Playground.argparse(["activate"])
    @test args == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => "",
        )
    )
end

let args = Playground.argparse(["activate", "./myplayground"])
    @test args == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "./myplayground",
            "name" => "",
        )
    )
end

let args = Playground.argparse(["activate", "myplayground"])
    @test args == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => "myplayground",
        )
    )
end

let args = Playground.argparse(["exec", "myplayground", "ls -la"])
    @test args == Dict(
        "%COMMAND%" => "exec",
        "exec" => Dict(
            "name" => "myplayground",
            "dir" => "",
            "cmd" => "ls -la",
        )
    )
end

let args = Playground.argparse(["list", "--show-links"])
    @test args == Dict(
        "%COMMAND%" => "list",
        "list" => Dict(
            "show-links" => true,
        )
    )
end

let args = Playground.argparse(["clean"])
    @test args == Dict(
        "%COMMAND%" => "clean",
        "clean" => Dict(),
    )
end

let args = Playground.argparse(["rm", "myplayground"])
    @test args == Dict(
        "%COMMAND%" => "rm",
        "rm" => Dict(
            "name" => "myplayground",
            "dir" => "",
        )
    )
end
