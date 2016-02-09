using Lint

# Run lint Playground.jl for Error or Critical level message
msgs = lintpkg("Playground", returnMsgs=true)
for m in msgs
    # Deal with issues that exist in Lint.jl
    if endswith(m.message, "type assertion and default seem inconsistent")
        level = 2
    elseif startswith(m.message, "cannot find include file")
        level = 3
    else
        level = 1
    end

    @test m.level <= level
end
