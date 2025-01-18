@testset "data" begin
    @test_throws ArgumentError ggplot(data = ["not", "a", "DataFrame"])
    @test_throws ArgumentError geom_point((data = ["not", "a", "DataFrame"]),
        aes(x = :x, y = :y))

    @test c(1, 2, 3) == [1, 2, 3]
    @test_nowarn c(1, 2, 3)
end
