@testset "legend operations" begin
    g = ggplot() + guides(color = "legend")

    @test g.legend_options[:color][:guide] == :legend

    g2 = ggplot() +
        scale_color_discrete(palette = :julia) +
        guides(color = "legend")

    @test g2.legend_options[:color][:guide] == :legend
    @test g2.legend_options[:color][:type] == "discrete"
    @test g2.legend_options[:color][:palette] == :julia

    p1 = ggplot(penguins) +
        geom_point(
            aes(x = :bill_length_mm, y = :bill_depth_mm, color = :sex)
        ) +
        scale_color_discrete(palette = :julia) +
        guides(color = "auto")

    p2 = ggplot(penguins) +
        geom_point(
            aes(x = :bill_length_mm, y = :bill_depth_mm, color = :sex)
        ) +
        scale_color_discrete(palette = :julia) +
        guides(color = "legend")

    @test plot_images_equal(p1, p2)

    p1 = ggplot(penguins) +
        geom_point(
            aes(x = :bill_length_mm, y = :bill_depth_mm, color = :bill_depth_mm)
        ) +
        scale_color_continuous(palette = :julia) +
        guides(color = "auto")

    p2 = ggplot(penguins) +
        geom_point(
            aes(x = :bill_length_mm, y = :bill_depth_mm, color = :bill_depth_mm)
        ) +
        scale_color_continuous(palette = :julia) +
        guides(color = "colorbar")

    @test plot_images_equal(p1, p2)

end
