
function test_activate()
    function Base.run(cmd::Cmd)
        return cmd
    end

    activate(TEST_CONFIG; dir=joinpath(TEST_TMP_DIR, "test-playground"))
    activate(TEST_CONFIG; name="myproject")
    activate(TEST_CONFIG; name="otherproject")
    activate(TEST_CONFIG)
end


test_activate()
