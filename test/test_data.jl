@testset "data" begin
    @test_throws ArgumentError ggplot(data = ["not", "a", "DataFrame"])
    @test_throws ArgumentError geom_point((data = ["not", "a", "DataFrame"]),
        aes(x = :x, y = :y))
end
