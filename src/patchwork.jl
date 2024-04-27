# functions to implement the functionality of R's {patchwork} package
function combine_plots(catfunc::Function, args::Union{GGPlot,GGPlotGrid}...)
    all_plots = GGPlot[]
    for a in args
        if isa(a, GGPlot)
            push!(all_plots, a)
        else
            push!(all_plots, a.plots...)
        end
    end
    all_axes = [isa(a, GGPlot) ? SpecApi.Axis(a) : a.grid for a in args]
    return GGPlotGrid(
        all_plots,
        SpecApi.GridLayout(
            catfunc(
                all_axes...
            )
        )
    )
end

# + -> side by side
Base.:+(args::Union{GGPlot, GGPlotGrid}...) = combine_plots(hcat, args...)

# | -> side by side
Base.:|(args::Union{GGPlot, GGPlotGrid}...) = combine_plots(hcat, args...)

# / -> p1 above p2
Base.:/(args::Union{GGPlot, GGPlotGrid}...) = combine_plots(vcat, args...)
