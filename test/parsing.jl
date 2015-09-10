function test_argparse()
    args = argparse(["install", "download", "0.3", "--labels", "julia-0.3"])
    @compat @test args == Dict(
        "install" => Dict(
            "download" => Dict(
                "version" => "0.3",
                "labels" => "julia-0.3"
            )
        )
    )
end

test_argparse()
