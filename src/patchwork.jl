# functions to implement the functionality of R's {patchwork} package

function Base.:+(plot1::GGPlot, plot2::GGPlot)
    return GGPlotGrid(
        [plot1, plot2],
        SpecApi.GridLayout([Makie.SpecApi.Axis(plot1) Makie.SpecApi.Axis(plot2)])
    )
end

function Base.:/(plot1::GGPlot, plot2::GGPlot)
    return GGPlotGrid(
        [plot1, plot2],
        SpecApi.GridLayout([Makie.SpecApi.Axis(plot1), Makie.SpecApi.Axis(plot2)])
    )
end