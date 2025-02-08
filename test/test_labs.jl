@testset "labs" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

    m_title = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; title="Title"
            )
        )
    )

    @test plot_images_equal(t + labs(title="Title"), m_title)

    m_xlab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X"), m_xlab)

    m_ylab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; ylabel="Y"
            )
        )
    )

    @test plot_images_equal(t + labs(y="Y"), m_ylab)

    m_xylab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X", ylabel="Y"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X", y="Y"), m_xylab)

    m_xylab_title = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X", ylabel="Y", title="Title"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X", y="Y", title="Title"), m_xylab_title)

    l = labs(ggplot(), x="Test")

    @test l.axis_options.opt[:xlabel] == "Test"

end
