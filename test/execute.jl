@testset "execute" begin
    execute(`ls -al`, TEST_CONFIG, "myproject")
    execute(`julia -v`, TEST_CONFIG, join(TEST_TMP_DIR, "test-playground"))
end
