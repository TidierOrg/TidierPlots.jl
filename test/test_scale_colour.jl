@testset "color scales" verbose = true begin
    @testset "discrete" begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:species)) +
            scale_color_discrete(palette="julia")

        colours = ColorSchemes.colorschemes[:julia]

        cat_array = CategoricalArray(penguins.species)

        l = Makie.SpecApi.Legend(
            [MarkerElement(color=colours[1], markersize=12, marker=:circle),
                MarkerElement(color=colours[2], markersize=12, marker=:circle),
                MarkerElement(color=colours[3], markersize=12, marker=:circle)],
            ["Adelie", "Chinstrap", "Gentoo"],
            " ")

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=(x -> colours[x]).(levelcode.(cat_array))
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_discrete()
        @test_throws ArgumentError md = TidierPlots.make_color_lookup_discrete(
            Dict(:wrongname => [1])
        )
        @test_throws ArgumentError md = TidierPlots.make_color_lookup_discrete(
            Dict(:palette => [1])
        )

        s = scale_color_discrete(palette="julia")
        @test s.palette[:color](1) == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](["a"])[1] == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](1.2) == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](CategoricalArray(["a"]))[1] ==
              Colors.RGB{N0f8}(0.122, 0.514, 1.0)
    end

    @testset "manual" begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:species)) +
            scale_color_manual("red", "white", "blue")

        colours = parse.(Colorant, ["red", "white", "blue"])

        cat_array = CategoricalArray(penguins.species)

        l = Makie.SpecApi.Legend(
            [MarkerElement(color=colours[1], markersize=12, marker=:circle),
                MarkerElement(color=colours[2], markersize=12, marker=:circle),
                MarkerElement(color=colours[3], markersize=12, marker=:circle)],
            ["Adelie", "Chinstrap", "Gentoo"],
            " ")

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=(x -> colours[x]).(levelcode.(cat_array))
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        ml = TidierPlots.make_color_lookup_manual(
            Dict(:values => [:red, :blue, :white])
        )

        @test all(ml([1.2, 1.8]) .== [Colors.RGB(1.0, 0.0, 0.0), Colors.RGB(0.0, 0.0, 1.0)])
    end

    @testset "continuous" begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:bill_depth_mm)) +
            scale_color_continuous(palette=:Purples_5)

        colours = get(ColorSchemes.colorschemes[:Purples_5],
            penguins.bill_depth_mm ./ maximum(penguins.bill_depth_mm))

        l = Makie.SpecApi.Colorbar(; colormap=:Purples_5,
            limits=(minimum(penguins.bill_depth_mm),
                maximum(penguins.bill_depth_mm)), label=" ")

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=colours
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_continuous()
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_continuous(Dict(:palette => [1]))
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_continuous(Dict(:wrongname => [1]))


        s = scale_color_continuous(palette="julia")
        @test s.palette[:color](1) == RGB{Float64}(
            0.5725490196078431,
            0.34901960784313724,
            0.6392156862745098)

        gg1 = ggplot(DataFrame(x = [1.0,2.2], y = [1.1,2.3])) +
            geom_point(aes(x = :x, y = :y, color = :x))

        gg2 = ggplot(DataFrame(x = [1.0,2.2], y = [1.1,2.3])) +
            geom_point(aes(x = :x, y = :y, color = :x)) + scale_colour_continuous(palette = :viridis) +
            guides(color = "none")

        @test plot_images_equal(gg1, gg2)

    end

    @testset "binned" begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:bill_depth_mm)) +
            scale_color_binned(palette=:Purples_5)

        input = penguins.bill_depth_mm

        colours = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))

        l = Makie.SpecApi.Colorbar(;
            colormap=cgrad(:Purples_5, 5, categorical=true),
            limits=(minimum(penguins.bill_depth_mm),
                maximum(penguins.bill_depth_mm)), label=" ")

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=ColorSchemes.colorschemes[:Purples_5][colours]
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_binned()
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_binned(Dict(:palette => [1]))
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_binned(Dict(:wrongname => [1]))
    end

    @test_throws ArgumentError TidierPlots.color_scale_to_ggoptions(
        Dict(
            :type => "manual",
            :scale => "bad",
            :values => [:red, :blue]
        )
    )

    tfill = TidierPlots.color_scale_to_ggoptions(
        Dict(
            :type => "manual",
            :scale => "fill",
            :values => [:red, :blue]
        )
    )
    @test tfill.palette[:fill](1)[1] == Colors.RGB(1.0, 0.0, 0.0)
end
