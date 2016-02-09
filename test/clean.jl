let name = "orphan", root_dir = joinpath(TMP_DIR, "playground")
    playground = Playground.create_playground(
        root=root_dir,
        name=name,
    )

    link = joinpath(Playground.CORE.share_dir, name)

    # Delete the playground directory improperly leaving the global name pointing to nothing
    rm(root_dir, recursive=true)

    @test !isdir(root_dir)
    @test islink(link)
    @test readlink(link) == root_dir

    Playground.clean()

    @test !islink(link)
end
