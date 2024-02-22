function handle_position(dicts)
    handle_position(dicts[1], dicts[2])
end

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


"""
    geom_col(aes(...), ...)
    geom_col(plot::GGPlot, aes(...), ...)
    
    Represent data as bars. 

    # Arguments

    - plot::GGPlot (optional): a plot object to "add" this geom to
    - `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
    - `...`: options that are not mapped to a column 

    # Required Aesthetics

    - x
    - y

    # Supported Optional Aesthetics

    - alpha
    - colour/color
    - fill
    - group
    - linetype
    - linewidth

    # Supported Options

    - alpha
    - colour/color
    - fill
    - group
    - linetype
    - linewidth

"""
geom_col = geom_template("geom_col", ["x", "y"], Makie.SpecApi.BarPlot)
