
function test_argparse()
    install_download_args = argparse(["install", "download", "0.3"])
    @test install_download_args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "download",
            "download" => Dict(
                "labels" => AbstractString[],
                "version" => v"0.3",
            )
        )
    )

    install_link_args = argparse(["install", "link", "/path/to/julia", "--labels", "julia-src"])
    @test install_link_args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "link",
            "link" => Dict(
                "labels" => AbstractString["julia-src"],
                "dir" => "/path/to/julia"
            )
        )
    )

    create_args1 = argparse(["create"])
    @test create_args1 == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "dir" => "",
            "requirements" => "",
            "name" => "",
            "julia-version" => "",
        )
    )

    create_args2 = argparse(
        [
            "create", "/path/to/playground",
            "--name", "myplayground",
            "--julia-version", "julia-0.3",
            "--requirements", "/path/to/requirements",
        ]
    )

    activate_args1 = argparse(["activate"])
    @test activate_args1 == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => ""
        )
    )

    activate_args2 = argparse(["activate", "--name", "myplayground"])
    @test activate_args2 == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => "myplayground"
        )
    )

    exec_args = argparse(["exec", "ls -al", "--name", "myplayground"])
    @test exec_args == Dict(
        "%COMMAND%" => "exec",
        "exec" => Dict(
            "cmd" => "ls -al",
            "dir" => "",
            "name" => "myplayground"
        )
    )

    list_args = argparse(["list", "--show-links"])
    @test list_args == Dict(
        "%COMMAND%" => "list",
        "list" => Dict(
            "show-links" => true
        )
    )

    clean_args = argparse(["clean"])
    @test clean_args == Dict(
        "%COMMAND%" => "clean",
        "clean" => Dict()
    )

    rm_args = argparse(["rm", "myplayground"])
    @test rm_args == Dict(
        "%COMMAND%" => "rm",
        "rm" => Dict(
            "dir" => "",
            "name" => "myplayground"
        )
    )
end

test_argparse()
