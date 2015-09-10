
function test_argparse()
    install_download_args = argparse(["install", "download", "0.3", "--labels", "julia-0.3"])
    @compat @test install_download_args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "download",
            "download" => Dict(
                "labels" => ["julia-0.3"],
                "version" => "0.3"
            )
        )
    )

    install_link_args = argparse(["install", "link", "/path/to/julia", "--labels", "julia-src"])
    @compat @test install_link_args == Dict(
        "%COMMAND%" => "install",
        "install" => Dict(
            "%COMMAND%" => "link",
            "link" => Dict(
                "labels" => ["julia-src"],
                "dir" => "/path/to/julia"
            )
        )
    )

    create_args1 = argparse(["create"])
    @compat @test create_args1 == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "dir" => "",
            "requirements" => "",
            "name" => "",
            "julia-version" => "",
            "req-type" => "REQUIRE"
        )
    )

    create_args2 = argparse(
        [
            "create", "/path/to/playground",
            "--name", "myplayground",
            "--julia-version", "julia-0.3",
            "--requirements", "/path/to/requirements",
            "--req-type", "DECLARE"
        ]
    )
    @compat @test create_args2 == Dict(
        "%COMMAND%" => "create",
        "create" => Dict(
            "dir" => "/path/to/playground",
            "requirements" => "/path/to/requirements",
            "name" => "myplayground",
            "julia-version" => "julia-0.3",
            "req-type" => "DECLARE"
        )
    )

    activate_args1 = argparse(["activate"])
    @compat @test activate_args1 == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => ""
        )
    )

    activate_args2 = argparse(["activate", "--name", "myplayground"])
    @compat @test activate_args2 == Dict(
        "%COMMAND%" => "activate",
        "activate" => Dict(
            "dir" => "",
            "name" => "myplayground"
        )
    )

    list_args = argparse(["list", "--show-links"])
    @compat @test list_args == Dict(
        "%COMMAND%" => "list",
        "list" => Dict(
            "show-links" => true
        )
    )

    clean_args = argparse(["clean"])
    @compat @test clean_args == Dict(
        "%COMMAND%" => "clean",
        "clean" => Dict()
    )

    rm_args = argparse(["rm", "myplayground"])
    @compat @test rm_args == Dict(
        "%COMMAND%" => "rm",
        "rm" => Dict(
            "dir" => "",
            "name" => "myplayground"
        )
    )
end

test_argparse()
