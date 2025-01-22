@testset "data" begin
    @test_throws ArgumentError ggplot(data=["not", "a", "DataFrame"])
    @test_throws ArgumentError geom_point((data = ["not", "a", "DataFrame"]),
        aes(x=:x, y=:y))

    @test c(1, 2, 3) == [1, 2, 3]
    @test_nowarn c(1, 2, 3)

    gg1 = ggplot(data=DataFrame(a=[1, 2]))
    gg2 = ggplot(DataFrame(a=[1, 2]))

    @test all(gg1.data.a .== gg2.data.a)
end
