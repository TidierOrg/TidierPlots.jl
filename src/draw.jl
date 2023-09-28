function draw_ggplot(plot::GGPlot)
    
    layers = Layers(plot)

    supported_label_options = Dict("title" => "title",
                                   "subtitle" => "subtitle",
                                   "y" => "ylabel",
                                   "x" => "xlabel",
                                   "height" => "height",
                                   "width" => "width",
                                   "limits" => "limits",
                                   "xscale" => "xscale",
                                   "yscale" => "yscale",
                                   "xreversed" => "xreversed",
                                   "yreversed" => "yreversed")

    provided_label_options = intersect(
        keys(supported_label_options),
        keys(plot.axis_options)
    )

    # this creates a named tuple
    label_options = (;[Symbol(supported_label_options[key]) => plot.axis_options[key] for key in provided_label_options]...)

    if haskey(plot.axis_options, "palettes")
        if plot.axis_options["color_palette_type"] == "manual"
            draw(layers; axis = label_options, palettes = plot.axis_options["palettes"])
        elseif plot.axis_options["color_palette_type"] == "discrete"
            # which column is assigned to colour? 
            if haskey(plot.default_aes, "colour") 
                colour_column = plot.default_aes["colour"]
            elseif haskey(plot.default_aes, "color")
                colour_column = plot.default_aes["color"]
            else
                for g in plot.geoms
                    if haskey(g.aes, "color")
                        colour_column = g.aes["color"]
                    elseif haskey(g.aes, "colour")
                        colour_column = g.aes["colour"]
                    end
                end
            end

            #how many colours do we need? 
            plot_data = DataFrame(plot.data.data)
            ncolours = length(unique(plot_data[!, colour_column]))
        
            draw(layers; axis = label_options, palettes = (color = cgrad(plot.axis_options["palettes"], ncolours, categorical=true), ))
        end
    else
        draw(layers; axis = label_options)
    end
end