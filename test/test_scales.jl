@testset "scale_x/y_continuous" begin
    t = ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm)) +
        geom_point() +
        scale_x_continuous(
            name="Mass (g)",
            trans=log10
        ) +
        scale_y_continuous(
            name="Length",
            reversed=true,
            labels=label_number(; suffix="mm")
        )

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.body_mass_g,
                        penguins.bill_length_mm;
                    )],
                xlabel="Mass (g)",
                xscale=log10,
                ylabel="Length",
                yreversed=true,
                ytickformat=label_number(; suffix="mm")),
        ])
    )

    @test plot_images_equal(t, m)

    scale = TidierPlots.continuous_scale_to_ggoptions(
        Dict("scale" => "x", "trans" => log, "reversed" => true)
    )
    @test scale.opt[:xreversed] == true
    @test scale.opt[:xscale] == log

    scale = scale_x_reverse()

    @test scale.opt[:xreversed] == true

    t = ggplot(DataFrame(x=[1, 2], y=[2, 3], shape=["a", "b"])) +
        geom_point(aes(x=:x, y=:y, shape=:shape)) + scale_shape()

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        [1, 2],
                        [2, 3]; marker=[:circle, :cross]
                    )]
            ), (1, 2) => Makie.SpecApi.Legend(
                [MarkerElement(marker=:circle, markersize=12),
                    MarkerElement(marker=:cross, markersize=12)],
                ["a", "b"], "marker"
            )
        ])
    )

    @test plot_images_equal(t, m)

    t = ggplot(DataFrame(x=[1, 2], y=[2, 3])) +
        geom_point(aes(x=:x, y=:y, size=:y)) + scale_size(range=[5, 10])

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        [1, 2],
                        [2, 3]; markersize=[5, 10]
                    )]
            ), (1, 2) => Makie.SpecApi.Legend(
                [MarkerElement(marker=:circle, markersize=5),
                    MarkerElement(marker=:circle, markersize=6.25),
                    MarkerElement(marker=:circle, markersize=7.5),
                    MarkerElement(marker=:circle, markersize=8.75),
                    MarkerElement(marker=:circle, markersize=10)],
                ["2.0", "2.25", "2.5", "2.75", "3.0"], "markersize"
            )
        ])
    )

    @test plot_images_equal(t, m)

    t = ggplot(DataFrame(x=[1, 2, 1, 2],
        y=[2, 3, 1, 4],
        l=[1, 1, 2, 2])) +
        geom_line(aes(x=:x, y=:y, group=:l, linewidth=:l))

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [2, 3];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0)
                    ),
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [1, 4];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0), linewidth=2
                    )]
            )
        ])
    )

    @test plot_images_equal(t, m)
end
