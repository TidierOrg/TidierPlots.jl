@testset "ggsave" begin
    plot = ggplot()
    path = tempname() * ".png"
    @test_throws ArgumentError ggsave(plot, path; height = 100)
    @test_throws ArgumentError ggsave(plot, path; width = 100)

    @test_nowarn ggsave(plot, path)
    @test_nowarn ggsave(path, plot)
    @test_nowarn ggsave(plot, path; height = 100, width = 100)

    g1 = ggplot(DataFrame(x = [1,3], y = [1,3])) +
        geom_point(aes(x = :x, y = :y))
    g2 = ggplot(DataFrame(x = [1,2], y = [1,2])) +
        geom_point(aes(x = :x, y = :y))

    gg = g1 + g2

    @test_nowarn draw_ggplot(gg, (300, 300))
end
