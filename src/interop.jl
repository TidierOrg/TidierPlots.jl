Layer(geom::Geom) = geom_to_layer(geom, geom.data, geom.axis_options)

function Layers(plot::GGPlot)
    layers = []
    empty_layer = mapping()
    
    for geom in plot.geoms
        # if an aes isn't given in the geom, use the ggplot aes
        for aes in keys(plot.default_aes)
            if !haskey(geom.aes, aes)
                geom.aes[aes] = plot.default_aes[aes]
            end
        end

        # if data is not specified at the geom level, use the ggplot default
        if layer_equal(geom.data, empty_layer)
            data = plot.data
        else 
            data = geom.data
        end

        data_with_na = DataFrame(data.data)
        data_without_na = dropmissing(DataFrame(data.data), String.(values(geom.aes)))

        if nrow(data_with_na) != nrow(data_without_na)
            name = geom.args["geom_name"]
            number = nrow(data_with_na) - nrow(data_without_na)
            @warn("$name will not plot $number rows with missing values.")
            data = AlgebraOfGraphics.data(data_without_na)
        end

        push!(layers, geom_to_layer(geom, data, plot.axis_options))
    end

    if length(layers) == 0
        error("No geoms found. A ggplot requires at least one geom.")
    elseif length(layers) == 1
        combined = layers[1]
    else
        combined = (+)(layers...)
    end

    return(combined)
end