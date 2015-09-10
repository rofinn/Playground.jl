# Run lint Playground.jl for Error or Critical level message
msgs = lintpkg("Playground", returnMsgs=true)
for m in msgs
    @test m.level < 2
end
