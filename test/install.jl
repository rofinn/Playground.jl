@testset "install" begin
    @testset "Download" begin
        @testset "Errors" begin
            base_name = "julia-0.3_$(Dates.today())"
            tmp_dest = join(TEST_CONFIG.tmp, base_name)

            try
                touch(tmp_dest)

                patch = @patch contains(text::AbstractString, str::AbstractString) = true
                Mocking.apply(patch) do
                    @test_throws ErrorException install(TEST_CONFIG, v"0.3.0")
                end

                patch = @patch contains(text::AbstractString, str::AbstractString) = false
                Mocking.apply(patch) do
                    @test_throws ErrorException install(TEST_CONFIG, v"0.3.0")
                end
            finally
                remove(tmp_dest)
            end
        end

        @testset "Pass" begin
            install(TEST_CONFIG, v"0.4.0"; labels=["julia-bin", "julia-old-bin"])
            install(TEST_CONFIG, v"0.5.0"; labels=["julia-bin", "julia-stable-bin"])
            install(TEST_CONFIG, v"0.6.0-latest"; labels=["julia-nightly-bin"])
        end
    end

    @testset "Link" begin
        @testset "Errors" begin
            @testset "Invalid path" begin
                @test_throws ErrorException install(TEST_CONFIG, p"bad"; labels=["julia-bad"])
            end
        end
        @testset "Pass" begin
            install(
                TEST_CONFIG,
                join(TEST_CONFIG.bin, "julia-nightly-bin");
                labels=["julia-nightly-dir"]
            )
            install(
                TEST_CONFIG,
                join(TEST_CONFIG.bin, "julia-stable-bin");
                labels=["julia-stable-dir"]
            )
        end
    end
end
