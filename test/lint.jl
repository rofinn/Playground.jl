# Run lint Playground.jl for Error or Critical level message
msgs = lintpkg("Playground", returnMsgs=true)
for m in msgs
    # Note Lint.jl doesn't seem to handle parametric functions correctly
    level = m.message == "args type assertion and default seem inconsistent" ? 2 : 1
    @test m.level <= level
end
