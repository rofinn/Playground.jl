
@testset "utils" begin
    @test contains(basename(Playground.julia_url(Playground.NIGHTLY)), "julia-latest")
    @test contains(basename(Playground.julia_url(v"0.4+")), "julia-0.4-latest")
    @test contains(basename(Playground.julia_url(v"0.4")), "julia-0.4.0")
    @test_throws ArgumentError Playground.julia_url(Base.nextpatch(Playground.NIGHTLY))

    @test contains(basename(Playground.julia_url("nightly")), "julia-latest")
    @test ismatch(r"julia-.*-latest", basename(Playground.julia_url("release")))
    @test contains(basename(Playground.julia_url("0.4")), "julia-0.4.0")

    # Testing coverage
    versions = (v"0.5", v"0.6", v"0.7-")
    platforms = (:Darwin, :Linux, :Windows)
    archs = (32, 64)
    @testset "julia $v on $p-$a" for v in versions, p in platforms, a in archs
        if p === :Darwin && a == 32
            @test_throws ErrorException Playground.julia_url(v, p, a)
        else
            @test !isempty(Playground.julia_url(v, p, a))
        end
    end
end
