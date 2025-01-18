@testset "legend operations" begin
    g = ggplot() + guides(color = "legend")
    @test g.legend_options[:color][:guide] == :legend

    g2 = ggplot() +
        scale_color_discrete(palette = :julia) +
        guides(color = "legend")

    @test g2.legend_options[:color][:guide] == :legend
    @test g2.legend_options[:color][:type] == "discrete"
    @test g2.legend_options[:color][:palette] == :julia

end
