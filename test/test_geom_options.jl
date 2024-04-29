@testset "geom_options" verbose = true begin
@testset "inherit aes" begin
    t = ggplot(penguins, aes(color = :species)) + 
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm), inherit_aes = false)
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )

    @test plot_images_equal(t, m) 
end
end
