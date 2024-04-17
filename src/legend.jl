function build_legend(plot::GGPlot)
    # what aes will automatically have a legend built for them?
    auto_legend = [:color]

    if haskey(plot.column_transformations, :color)
        palette_function = plot.column_transformations[:color][2]
    else
        return nothing
    end  

    legend = DataFrame(labels = String[], colors = Any[], options = Any[], element = Any[])
    title = nothing

    for geom in plot.geoms
        
        color_colname = haskey(geom.aes, "colour") ? geom.aes["colour"] :
            haskey(geom.aes, "color") ? geom.aes["color"] :
            nothing
        
        if !isnothing(color_colname)
            plot_data = isnothing(geom.data) ? plot.data : geom.data
            plottable_data = palette_function(:color, [color_colname], plot_data)
            labels = unique(plottable_data[:color].raw)

            append!(legend, sort(DataFrame(labels = labels,
                colors = unique(plottable_data[:color].makie_function(plottable_data[:color].raw)),
                options = _legend_geom_symbols[geom.args["geom_name"]],
                element = _legend_geom_elements[geom.args["geom_name"]]), 
                :labels))
            
            title = titlecase(string(color_colname))
        end
    end

    #return legend

    if nrow(legend) == 0
        return nothing
    end

    labels = String[]
    elems = Any[]

    for (k, v) in pairs(groupby(legend, :labels))
        push!(elems, [l.element(color = l.colors; l.options...) for l in eachrow(v)])
        push!(labels, string(v.labels[1]))
    end

    return Makie.SpecApi.Legend(elems, labels, title)
end