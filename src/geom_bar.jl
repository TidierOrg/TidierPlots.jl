macro geom_bar(exprs...)
    ##### This section should be consistent across all geoms ####

    # Extract arguments passed inside aes and outside aes into separate dictionaries 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    # If the geom has a data specification, store it in AoG format in geom.data
    # Otherwise draw_ggplot will use the data specified in @ggplot()

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    ##### This section is where the geoms are different ####

    # 1. What are the required aes arguments? They be specified inside this geom
    # or inherited from ggplot(), but if they are not given in either location,
    # the code will error. The order should be the same as expected by AoG's 
    # mapping() function for the plot that will be generated.

    required_aes = ["x"]

    # 2. What optional ggplot aes options are supported, and what is their name 
    # in AoG? 

    optional_aes = Dict("color" => "color",
                        "colour" => "color",
                        "stack" => "stack",
                        "dodge" => "dodge")

    if haskey(args_dict, "position")
        if args_dict["position"] == "stack"
            if haskey(aes_dict, "group")
                aes_dict["stack"] = aes_dict["group"]
            elseif haskey(aes_dict, "colour")
                aes_dict["stack"] = aes_dict["colour"]
            elseif haskey(aes_dict, "color")
                aes_dict["stack"] = aes_dict["color"]
            end
        elseif args_dict["position"] != "none"
            if haskey(aes_dict, "group")
                aes_dict["dodge"] = aes_dict["group"]
            elseif haskey(aes_dict, "colour")
                aes_dict["dodge"] = aes_dict["colour"]
            elseif haskey(aes_dict, "color")
                aes_dict["dodge"] = aes_dict["color"]
            end
        end
    else
        if haskey(aes_dict, "group")
            aes_dict["dodge"] = aes_dict["group"]
        elseif haskey(aes_dict, "colour")
            aes_dict["dodge"] = aes_dict["colour"]
        elseif haskey(aes_dict, "color")
            aes_dict["dodge"] = aes_dict["color"]
        end
    end

    # 3. If the plot requires a call to AoG's visual() function, geom_visual should
    # contain the AoG function visual, the Makie function that visual expects as its 
    # first argument, and any required settings. If a visual call 
    # is not required, this should be set to nothing

    geom_visual = AlgebraOfGraphics.visual(Makie.BarPlot) 

    # 4. If the plot requires a AoG analysis function, that function should be assigned 
    # here. If an AoG analysis is not required, set this to nothing

    analysis = AlgebraOfGraphics.frequency
    
    #### This return statement should not be edited ####

    return geom(geom_visual, aes_dict, args_dict,
                analysis, plot_data,
                required_aes, optional_aes)
end