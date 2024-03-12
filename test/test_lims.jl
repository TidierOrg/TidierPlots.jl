
@testset "lims" begin
    t = ggplot(penguins) + 
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

    m_xlim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter, 
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits = ((30, 60), (nothing, nothing))
            )
        )
    )

    @test plot_images_equal(t + lims(x = (30, 60)), m_xlim)

    m_ylim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter, 
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits = ((nothing, nothing), (10, 25))
            )
        )
    )

    @test plot_images_equal(t + lims(y = (10, 25)), m_ylim)

    m_xylim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter, 
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits = ((30, 60), (10, 25))
            )
        )
    )

    @test plot_images_equal(t + lims(x = (30, 60), y = (10, 25)), m_xylim)
end