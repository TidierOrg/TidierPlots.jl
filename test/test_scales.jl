@testset "scale_x/y_continuous" begin
    t = ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm)) +
            geom_point() +
            scale_x_continuous(
                name="Mass (g)",
                trans=log10
            ) +
            scale_y_continuous(
                name="Length",
                reversed = true,
                labels=label_number(;suffix="mm")
            )

    m = Makie.plot(
            Makie.SpecApi.GridLayout([
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.body_mass_g,
                            penguins.bill_length_mm;
                        )],
                    xlabel = "Mass (g)",
                    xscale = log10,
                    ylabel = "Length",
                    yreversed = true,
                    ytickformat = label_number(; suffix="mm")),
            ])
        )

    @test plot_images_equal(t, m)
end

