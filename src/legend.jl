function build_legend(plot::GGPlot)
    # what aes will automatically have a legend built for them?
    auto_legend = [:color]


    # what element by default for each geom?
    geom_elements = Dict{String, Any}(
        "geom_point" => MarkerElement,
        "geom_line" => LineElement
    )

    # what options by default for each geom? 
    geom_symbols = Dict{String, Dict}(
        "geom_point" => Dict(:marker => :circle, :markersize => 12),
        "geom_line" => Dict(:linestyle => nothing)
    )

    

    if haskey(plot.column_transformations, :color)
        palette_function = plot.column_transformations[:color][2]
    else
        return nothing
    end  

    legend = DataFrame(labels = String[], colors = Any[], options = Any[], element = Any[])
    title = nothing

    for geom in plot.geoms
        color_colname = nothing
        
        if haskey(geom.aes, "colour")
            color_colname = geom.aes["colour"]
        end

        if haskey(geom.aes, "color") 
            color_colname = geom.aes["color"]
        end
        
        if !isnothing(color_colname)
            plot_data = isnothing(geom.data) ? plot.data : geom.data
            plottable_data = palette_function(:color, [color_colname], plot_data)
            labels = unique(plottable_data[:color].raw)

            append!(legend, sort(DataFrame(labels = labels,
                colors = unique(plottable_data[:color].makie_function(plottable_data[:color].raw)),
                options = geom_symbols[geom.args["geom_name"]],
                element = geom_elements[geom.args["geom_name"]]), 
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