function build_legend(plot::GGPlot)
    # what aes will automatically have a legend built for them?
    auto_legend = [:color, :strokecolor]

    palette_function = nothing

    if !(any([haskey(geom.aes, :colour) || haskey(geom.aes, :color) for geom in plot.geoms]) ||
         haskey(plot.default_aes, :colour) ||
         haskey(plot.default_aes, :color))
        return nothing
    end

    legend = DataFrame(labels=String[], colors=Any[], options=Any[], element=Any[])
    title = nothing

    colorbar_kwargs = Dict()
    lowlim = Inf
    highlim = -Inf
    colorbar = false

    for geom in plot.geoms
        if !(geom.args["geom_name"] in keys(_legend_geom_symbols)) || !(geom.args["geom_name"] in keys(_legend_geom_elements))
            no_default =
                @warn "Legend defaults are not set for $(geom.args["geom_name"])."
            continue
        end

        if get(geom.args, "inherit_aes", true)
            all_aes = merge(plot.default_aes, geom.aes)
        else
            all_aes = geom.aes
        end

        color_colname = haskey(all_aes, :colour) ? all_aes[:colour][1] :
                        haskey(all_aes, :color) ? all_aes[:color][1] :
                        nothing

        if isnothing(color_colname)
            continue
        end

        plot_data = isnothing(geom.data) ? plot.data : geom.data
        palette_function = get(plot.palette, :color, nothing)

        if isnothing(palette_function)
            if eltype(plot_data[!, color_colname]) <: Union{AbstractString,AbstractChar,CategoricalValue}
                plot = plot + scale_colour_manual(values=[
                    RGB(0 / 255, 114 / 255, 178 / 255), # blue
                    RGB(230 / 255, 159 / 255, 0 / 255), # orange
                    RGB(0 / 255, 158 / 255, 115 / 255), # green
                    RGB(204 / 255, 121 / 255, 167 / 255), # reddish purple
                    RGB(86 / 255, 180 / 255, 233 / 255), # sky blue
                    RGB(213 / 255, 94 / 255, 0 / 255), # vermillion
                    RGB(240 / 255, 228 / 255, 66 / 255)]) # yellow)
            else
                plot = plot + scale_colour_continuous(palette=:viridis)
            end
            palette_function = plot.palette[:color]
        end

        if plot.legend_options[:color][:type] in ["manual", "discrete"]
            plottable_data = palette_function.(
                levelcode.(CategoricalArray(plot_data[!, color_colname]))
            )
            labels = unique(plot_data[!, color_colname])

            append!(legend, sort(DataFrame(labels=labels,
                    colors=unique(plottable_data),
                    options=_legend_geom_symbols[geom.args["geom_name"]],
                    element=_legend_geom_elements[geom.args["geom_name"]]),
                :labels))

            title = get(plot.legend_options[:color], :name, titlecase(string(color_colname)))
        end

        if plot.legend_options[:color][:type] in ["continuous", "binned"]

            plottable_data = palette_function(plot_data[!, color_colname])

            colorbar_kwargs[:colormap] = plot.legend_options[:color][:type] == "continuous" ? Symbol(plot.legend_options[:color][:palette]) :
                                         cgrad(Symbol(plot.legend_options[:color][:palette]), 5, categorical=true)

            lowlim = min(minimum(plot_data[!, color_colname]), lowlim)
            highlim = max(maximum(plot_data[!, color_colname]), highlim)

            colorbar = true
            title = get(plot.legend_options[:color], :name, titlecase(string(color_colname)))
        end
    end

    #return legend

    if nrow(legend) != 0
        labels = String[]
        elems = Any[]

        for (k, v) in pairs(groupby(legend, :labels))
            push!(elems, [l.element(color=l.colors; l.options...) for l in eachrow(v)])
            push!(labels, string(v.labels[1]))
        end

        return Makie.SpecApi.Legend(elems, labels, title)
    end

    if (colorbar)
        return Makie.SpecApi.Colorbar(; colorbar_kwargs..., limits=(lowlim, highlim), label=title)
    end

    return nothing
end
