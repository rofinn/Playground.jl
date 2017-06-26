function test_execute()
    execute(TEST_CONFIG, `ls -al`; name="myproject")
    execute(TEST_CONFIG, `julia -v`; dir=join(TEST_TMP_DIR, "test-playground"))
end

test_execute()
