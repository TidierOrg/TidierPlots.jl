macro geom_point(exprs...)
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

    required_aes = ["x", "y"]

    # 2. What optional ggplot aes options are supported, and what is their name 
    # in AoG? 

    optional_aes = Dict("color" => "color",
                        "colour" => "color",
                        "shape" => "marker",
                        "size" => "markersize",
                        "stroke" => "strokewidth",
                        "strokecolor" => "strokecolor",
                        "strokecolour" => "strokecolor",
                        "glow" => "glowwidth",
                        "glowcolor" => "glowcolor",
                        "glowcolour" => "glowcolor",
                        "alpha" => "alpha")

    # 3. If the plot requires a call to AoG's visual() function, geom_visual should
    # contain the AoG function visual, the Makie function that visual expects as its 
    # first argument, and any required settings. If a visual call 
    # is not required, this should be set to nothing
    
    optional_visual_args = optional_aes

    args_given = intersect(
        keys(optional_visual_args),
        keys(args_dict)
    )

    if length(args_given) != 0
        visual_args = Dict(Symbol(optional_visual_args[a]) => args_dict[a] for a in args_given)
        geom_visual = AlgebraOfGraphics.visual(Makie.Scatter; visual_args...)
    else
        geom_visual = AlgebraOfGraphics.visual(Makie.Scatter)
    end 

    # 4. If the plot requires a AoG analysis function, that function should be assigned 
    # here. If an AoG analysis is not required, set this to nothing

    analysis = nothing
   
    #### This return statement should not be edited ####

    return geom(geom_visual, aes_dict, args_dict,
        analysis, plot_data,
        required_aes, optional_aes)
end