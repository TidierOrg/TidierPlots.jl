@testset "ggsave" begin
    plot = ggplot()
    path = tempname() * ".png"
    @test_throws ArgumentError ggsave(plot, path; height = 100)
    @test_throws ArgumentError ggsave(plot, path; width = 100)

    @test_nowarn ggsave(plot, path)
    @test_nowarn ggsave(path, plot)
    @test_nowarn ggsave(plot, path; height = 100, width = 100)

end
