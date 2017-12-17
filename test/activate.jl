
@testset "activate" begin
    patch = @patch run(cmd::Base.AbstractCmd, args...) = println("Mocked: $cmd")

    Mocking.apply(patch) do
        activate(TEST_CONFIG, join(TEST_TMP_DIR, "test-playground"))
        activate(TEST_CONFIG, "myproject")
        activate(TEST_CONFIG)

        # Test activate when the SHELL environment isn't set.
        withenv("SHELL" => nothing) do
            activate(TEST_CONFIG)
        end
    end

    activate(Environment("myproject"); shell=false)
    deactivate()
end
