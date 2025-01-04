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
    all_axes = [isa(a, GGPlot) ? as_GridLayout(a) : a.grid for a in args]
    return GGPlotGrid(
        all_plots,
        Makie.SpecApi.GridLayout(
            catfunc(
                all_axes...
            )
        )
    )
end

# + -> side by side
function Base.:+(args::Union{GGPlot,GGPlotGrid,GGPlotGridSpec}...)
    if any(isa.(args, GGPlotGridSpec))
        return add_gridspec(args...)
    else
        return combine_plots(hcat, args...)
    end
end

# | -> side by side
Base.:|(args::Union{GGPlot,GGPlotGrid}...) = combine_plots(hcat, args...)

# / -> p1 above p2
Base.:/(args::Union{GGPlot,GGPlotGrid}...) = combine_plots(vcat, args...)

# Define plot layout
function plot_layout(; ncol=0, nrow=0, byrow=false, widths=Int[], heights=Int[])
    return GGPlotGridSpec(ncol, nrow, byrow, widths, heights)
end

function add_gridspec(args::Union{GGPlot,GGPlotGrid,GGPlotGridSpec}...)
    # Separate plots from gridspec
    plots = Union{GGPlot,GGPlotGrid}[]
    gridspec = nothing
    for arg in args
        if arg isa GGPlotGridSpec
            # Merge gridspecs
            if isnothing(gridspec)
                gridspec = arg
            else
                for k in fieldnames(GGPlotGridSpec)
                    setfield!(gridspec, getfield(arg, k))
                end
            end
        else
            push!(plots, arg)
        end
    end

    # Arrange plots
    nplots = length(plots)
    ncol = gridspec.ncol
    nrow = gridspec.nrow
    if (nrow == 0) & (ncol == 0)
        # Default: more cols than rows
        nrow = Int(round(sqrt(nplots)))
        ncol = Int(ceil(sqrt(nplots)))
    elseif (nrow == 0)
        # As many rows as needed
        nrow = Int(ceil(nplots / ncol))
    elseif (ncol == 0)
        # As many cols as needed
        ncol = Int(ceil(nplots / nrow))
    end
    layout = Pair{Tuple{Int64,Int64},Union{Makie.BlockSpec,Makie.GridLayoutSpec}}[]
    plot_i = 1
    if gridspec.byrow
        for j in 1:ncol, i in 1:nrow
            if plot_i <= nplots
                tmp_plot = plots[plot_i]
                axis = tmp_plot isa GGPlot ? as_GridLayout(tmp_plot) : tmp_plot.grid
                push!(layout, (i, j) => axis)
                plot_i += 1
            end
        end
    else
        for i in 1:nrow, j in 1:ncol
            if plot_i <= nplots
                tmp_plot = plots[plot_i]
                axis = tmp_plot isa GGPlot ? as_GridLayout(tmp_plot) : tmp_plot.grid
                push!(layout, (i, j) => axis)
                plot_i += 1
            end
        end
    end

    # Adjust sizes
    widths = isempty(gridspec.widths) ? ones(ncol) : gridspec.widths
    heights = isempty(gridspec.heights) ? ones(nrow) : gridspec.heights
    total_width = sum(widths)
    total_height = sum(heights)
    all_plots = GGPlot[]
    for p in plots
        if isa(p, GGPlot)
            push!(all_plots, p)
        else
            push!(all_plots, p.plots...)
        end
    end
    return GGPlotGrid(
        all_plots,
        Makie.SpecApi.GridLayout(
            layout,
            colsizes=[Relative(w / total_width) for w in widths],
            rowsizes=[Relative(h / total_height) for h in heights]
        )
    )
end
