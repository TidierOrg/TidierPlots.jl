function handle_position(aes_dict, args_dict, required_aes, plot_data)
    # handles defaults and grouping for geom_bar/col

    split_var = nothing

    if haskey(args_dict, "position")
        if args_dict["position"] == "dodge"
            if haskey(aes_dict, "group")
                aes_dict["dodge"] = aes_dict["group"]
                split_var = aes_dict["dodge"]
            elseif haskey(aes_dict, "colour")
                aes_dict["dodge"] = aes_dict["colour"]
                split_var = aes_dict["dodge"]
            elseif haskey(aes_dict, "color")
                aes_dict["dodge"] = aes_dict["color"]
                split_var = aes_dict["dodge"]
            end
        elseif args_dict["position"] != "none"
            if haskey(aes_dict, "group")
                aes_dict["stack"] = aes_dict["group"]
                split_var = aes_dict["stack"]
            elseif haskey(aes_dict, "colour")
                aes_dict["stack"] = aes_dict["colour"]
                split_var = aes_dict["stack"]
            elseif haskey(aes_dict, "color")
                aes_dict["stack"] = aes_dict["color"]
                split_var = aes_dict["stack"]
            end
        end
    else
        if haskey(aes_dict, "group")
            aes_dict["stack"] = aes_dict["group"]
            split_var = aes_dict["stack"]
        elseif haskey(aes_dict, "colour")
            aes_dict["stack"] = aes_dict["colour"]
            split_var = aes_dict["stack"]
        elseif haskey(aes_dict, "color")
            aes_dict["stack"] = aes_dict["color"]
            split_var = aes_dict["stack"]
        end
    end

    if args_dict["geom_name"] == "geom_bar"
        if haskey(aes_dict, "x") && !haskey(aes_dict, "y")
            grouping_var = Symbol(aes_dict["x"])
        elseif haskey(aes_dict, "y") && !haskey(aes_dict, "x")
            grouping_var = Symbol(aes_dict["y"])
            aes_dict["x"] = aes_dict["y"]
            delete!(aes_dict, "y")
            args_dict["direction"] = "x"
        else
            @error "geom_bar requires either an x or y aesthetic, but not both."
        end

        if !isnothing(split_var)
            plot_data = @chain plot_data begin
                group_by(grouping_var, split_var)
                @summarize(x = n())
            end
        else
            plot_data = @chain plot_data begin
                group_by(grouping_var)
                @summarize(x = n())
            end
        end
    end

    return (aes_dict, args_dict, required_aes, plot_data)
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
geom_col = geom_template("geom_col", ["x", "y"], :BarPlot; aes_function = handle_position)
geom_bar = geom_template("geom_bar", ["x"], :BarPlot; aes_function = handle_position)
