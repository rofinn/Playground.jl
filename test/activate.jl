
patch = @patch run(cmd::Base.AbstractCmd, args...) = println(cmd)

Mocking.apply(patch) do
    activate(TEST_CONFIG; dir=joinpath(TEST_TMP_DIR, "test-playground"))
    activate(TEST_CONFIG; name="myproject")
    activate(TEST_CONFIG)
end
