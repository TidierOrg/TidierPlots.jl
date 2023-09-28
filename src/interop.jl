function geom_to_layer(geom, data, labs)
    
    check_aes(geom.required_aes, geom.aes, geom.args["geom_name"])

    visual_layer = geom.visual

    if haskey(labs, "colormap")
        visual_layer = geom.visual * AlgebraOfGraphics.visual(colormap = labs["colormap"])
    end

    mapping_args_array = []

    # rename required aes if labs are given
    # this section is possibly not required with the current geoms
    # as x and y will be renamed elsewhere
    # it is retained in case geoms with required aes other than ["x", "y"]
    # are implemented 

    for key in geom.required_aes
        if haskey(labs, key * "_function")
            if haskey(labs, key)
                labs[key] = labs[key * "_function"] => labs[key]
            else
                labs[key] = labs[key * "_function"]
            end
        end
    end

    for key in geom.required_aes
        if !haskey(labs, key)
            push!(mapping_args_array, Symbol(geom.aes[key]))
        else 
            push!(mapping_args_array, Symbol(geom.aes[key]) => labs[key])
        end
    end
    
    mapping_args = Tuple(mapping_args_array)

    for key in keys(geom.optional_aes)
        if haskey(geom.args, key * "_function")
            if haskey(labs, key)
                labs[key] = eval(geom.args[key * "_function"]) => labs[key]
            else
                labs[key] = eval(geom.args[key * "_function"])
            end
        end
    end

    # check which supported optional aesthetics are available
    # and which ones have labels assigned to them

    available_optional_aes = intersect(
        keys(geom.aes),
        keys(geom.optional_aes)
    )

    labelled_optional_aes = intersect(
        keys(labs),
        available_optional_aes
    )

    unlabelled_optional_aes = symdiff(
        labelled_optional_aes, 
        available_optional_aes
    )

    # if any are available, multiply them in to the layer 
    # geom.optional_aes[a] gets the expected AoG arg name
    # geom_aes[a] gets the variable that was assigned to the aesthetic
    # if applicable, labs[a] gets the label that was assigned to the aes
    # if none are available, just use the required aes

    if length(available_optional_aes) != 0

        optional_mapping_args = merge(
            Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] for a in unlabelled_optional_aes),
            Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] => labs[a] for a in labelled_optional_aes)
        )

        layer = data * geom.analysis * visual_layer * mapping(mapping_args...; optional_mapping_args...)

    else
        layer = data * geom.analysis * visual_layer * mapping(mapping_args...)
    end    

    return layer
end

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

        # if there is no data in either, throw an error
        if layer_equal(data, empty_layer)
            name = geom.args["geom_name"]
            @error("No data found for $name. Either specify a data argument for each geom or specify a default for the ggplot.")
        end

        data_with_na = DataFrame(data.data)
        data_without_na = dropmissing(DataFrame(data.data), unique(String.(values(geom.aes))))

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