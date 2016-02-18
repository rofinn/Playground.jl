
@test contains(basename(Playground.julia_url(Playground.NIGHTLY)), "julia-latest")
@test contains(basename(Playground.julia_url(v"0.4+")), "julia-0.4-latest")
@test contains(basename(Playground.julia_url(v"0.4")), "julia-0.4.0")
@test_throws ArgumentError Playground.julia_url(Base.nextpatch(Playground.NIGHTLY))

@test contains(basename(Playground.julia_url("nightly")), "julia-latest")
@test ismatch(r"julia-.*-latest", basename(Playground.julia_url("release")))
@test contains(basename(Playground.julia_url("0.4")), "julia-0.4.0")

# Testing coverage
for v in (v"0.4", v"0.5-"), os in (:Darwin, :Linux, :Windows), arch in (32, 64)
    if os == :Darwin && arch == 32
        @test_throws ErrorException Playground.julia_url(v, os, arch)
    else
        @test !isempty(Playground.julia_url(v, os, arch))
    end
end
