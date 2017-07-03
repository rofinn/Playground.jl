
patch = @patch run(cmd::Base.AbstractCmd, args...) = println(cmd)

Mocking.apply(patch) do
    activate(TEST_CONFIG, join(TEST_TMP_DIR, "test-playground"))
    activate(TEST_CONFIG, "myproject")
    activate(TEST_CONFIG)
end

env = activate(Environment("myproject"); shell=false)
deactivate(env)
