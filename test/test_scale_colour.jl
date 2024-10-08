@testset "color scales" verbose = true begin
@testset "discrete" begin
    t = ggplot(penguins) +
           geom_point(aes(x = :bill_depth_mm, y = :bill_length_mm, color = :species)) +
           scale_color_discrete(palette = "julia")

    colours = ColorSchemes.colorschemes[:julia]

    cat_array = CategoricalArray(penguins.species)

    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            [Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_depth_mm,
                        penguins.bill_length_mm;
                        color = (x -> colours[x]).(levelcode.(cat_array))
                    )
                ]
            ) TidierPlots.build_legend(t)]
        )
    )

    @test plot_images_equal(t, m)
end

@testset "manual" begin
    t = ggplot(penguins) +
           geom_point(aes(x = :bill_depth_mm, y = :bill_length_mm, color = :species)) +
           scale_color_manual("red", "white", "blue")

    colours = parse.(Colorant, ["red", "white", "blue"])

    cat_array = CategoricalArray(penguins.species)

    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            [Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_depth_mm,
                        penguins.bill_length_mm;
                        color = (x -> colours[x]).(levelcode.(cat_array))
                    )
                ]
            ) TidierPlots.build_legend(t)]
        )
    )

    @test plot_images_equal(t, m)
end

@testset "continuous" begin
    t = ggplot(penguins) +
           geom_point(aes(x = :bill_depth_mm, y = :bill_length_mm, color = :bill_depth_mm)) +
           scale_color_continuous(palette = :Purples_5)

    colours = get(ColorSchemes.colorschemes[:Purples_5],
        penguins.bill_depth_mm ./ maximum(penguins.bill_depth_mm))

    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            [Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_depth_mm,
                        penguins.bill_length_mm;
                        color = colours
                    )
                ]
            ) TidierPlots.build_legend(t)]
        )
    )

    @test plot_images_equal(t, m)
end

@testset "binned" begin
    t = ggplot(penguins) +
           geom_point(aes(x = :bill_depth_mm, y = :bill_length_mm, color = :bill_depth_mm)) +
           scale_color_binned(palette = :Purples_5)

    input = penguins.bill_depth_mm

    colours = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))

    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            [Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_depth_mm,
                        penguins.bill_length_mm;
                        color = ColorSchemes.colorschemes[:Purples_5][colours]
                    )
                ]
            ) TidierPlots.build_legend(t)]
        )
    )

    @test plot_images_equal(t, m)
end
end
