let exec, vi
    # Make sure that the link created in bin_dir is new
    @test length(readdir(Playground.CORE.bin_dir)) == 0
    original = joinpath(JULIA_HOME, "julia")

    exec, vi = Playground.link_install(original)
    @test islink(exec)
    @test length(readdir(Playground.CORE.bin_dir)) == 1

    link = joinpath(Playground.CORE.bin_dir, "julia-nightly-dir")
    @test !ispath(link)
    Playground.julia_aliases(exec, ["julia-nightly-dir"])
    @test islink(link)
end

let exec, vi
    exec, vi = Playground.install(v"0.4.0")
    @test islink(exec)
    @test vi.version == v"0.4.0"

    link = joinpath(Playground.CORE.bin_dir, "julia-$(vi.version.major).$(vi.version.minor)")
    @test !ispath(link)
    Playground.julia_aliases(exec, vi)
    @test islink(link)

    # Ensure that downloading the same version twice works
    exec, vi = Playground.install(v"0.4.0")
    @test islink(exec)
end

let exec, vi
    exec, vi = Playground.install(v"0.5.0-")
    @test islink(exec)
    @test v"0.5-" <= vi.version <= v"0.5+"

    link = joinpath(Playground.CORE.bin_dir, "julia-nightly-bin")
    @test !ispath(link)
    Playground.julia_aliases(exec, ["julia-nightly-bin"])
    @test islink(link)
end
