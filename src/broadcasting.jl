# these functions only exist to allow broadcasting to work on ggplots

import Base.iterate
import Base.length

Base.iterate(p::TidierPlots.GGPlot) = (p, 1)
Base.iterate(p::TidierPlots.GGPlot, s::Any) = nothing
Base.length(p::TidierPlots.GGPlot) = 1

@testitem "Broadcasting" setup=[TidierPlotsSetup] begin
    plots = ggplot(penguins, aes(x=:bill_length_mm, y=:bill_depth_mm)) .+
            [geom_point(), geom_line(), geom_path()]

    t = +(plots...)

    mpoint = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Scatter,
                    penguins.bill_length_mm,
                    penguins.bill_depth_mm, color = :black)
            ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
    )

    mpath = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Lines,
                    penguins.bill_length_mm,
                    penguins.bill_depth_mm, color = :black)
            ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
    )

    perm = sortperm(penguins.bill_length_mm)

    mline = Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
            plots=[
                Makie.PlotSpec(
                    :Lines,
                    penguins.bill_length_mm[perm],
                    penguins.bill_depth_mm[perm], color = :black)
            ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
    )

    m = Makie.plot(Makie.SpecApi.GridLayout([mpoint mline mpath]))

    @test plot_images_equal(t, m)
end