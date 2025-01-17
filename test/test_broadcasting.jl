@testset "broadcasting" begin
    plots = ggplot(penguins, aes(x = :bill_length_mm, y = :bill_depth_mm)) .+
    [geom_point(), geom_line(), geom_path()]

    t = +(plots...)

    mpoint = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Scatter,
                    penguins.bill_length_mm,
                    penguins.bill_depth_mm)
                ]
        )
    )

    mpath = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Lines,
                    penguins.bill_length_mm,
                    penguins.bill_depth_mm)
                ]
        )
    )

    perm = sortperm(penguins.bill_length_mm)

    mline = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Lines,
                    penguins.bill_length_mm[perm],
                    penguins.bill_depth_mm[perm])
                ]
        )
    )

    m = Makie.plot(Makie.SpecApi.GridLayout([mpoint mline mpath]))

    @test plot_images_equal(t, m)
end
