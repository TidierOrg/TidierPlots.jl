macro geom_bar(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    aes_dict, args_dict = handle_position(aes_dict, args_dict)

    args_dict["geom_name"] = "geom_bar"
    
    return build_geom(aes_dict, args_dict, 
        ["x"], # required aesthetics
        Makie.BarPlot, # function for visual layer
        AlgebraOfGraphics.frequency()) # function for analysis layer

end

macro geom_col(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    aes_dict, args_dict = handle_position(aes_dict, args_dict)

    args_dict["geom_name"] = "geom_col"
    
    return build_geom(aes_dict, args_dict, 
        ["x"], # required aesthetics
        Makie.BarPlot, # function for visual layer
        mapping()) # function for analysis layer
end

macro geom_histogram(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_histogram"

    return build_geom(aes_dict, args_dict, 
        ["x"], # required aesthetics
        nothing, # function for visual layer
        AlgebraOfGraphics.histogram()) # function for analysis layer
end

geom_histogram = geom_template("geom_histogram", ["x"], nothing, AlgebraOfGraphics.histogram())

function handle_position(aes_dict, args_dict)
    
    # handles defaults and grouping for geom_bar 

    if haskey(args_dict, "position")
        if args_dict["position"] == "dodge"
            if haskey(aes_dict, "group")
                aes_dict["dodge"] = aes_dict["group"]
            elseif haskey(aes_dict, "colour")
                aes_dict["dodge"] = aes_dict["colour"]
            elseif haskey(aes_dict, "color")
                aes_dict["dodge"] = aes_dict["color"]
            end
        elseif args_dict["position"] != "none"
            if haskey(aes_dict, "group")
                aes_dict["stack"] = aes_dict["group"]
            elseif haskey(aes_dict, "colour")
                aes_dict["stack"] = aes_dict["colour"]
            elseif haskey(aes_dict, "color")
                aes_dict["stack"] = aes_dict["color"]
            end
        end
    else
        if haskey(aes_dict, "group")
            aes_dict["stack"] = aes_dict["group"]
        elseif haskey(aes_dict, "colour")
            aes_dict["stack"] = aes_dict["colour"]
        elseif haskey(aes_dict, "color")
            aes_dict["stack"] = aes_dict["color"]
        end
    end

    return (aes_dict, args_dict)
end

geom_col = geom_template("geom_col", ["x"], Makie.BarPlot, mapping(); dict_function = handle_position)