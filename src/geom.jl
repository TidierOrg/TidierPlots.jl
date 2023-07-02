function build_geom(aes_dict, args_dict, required_aes, visual, analysis)
    
    # if data is specified, call a questionable eval to grab it as a layer

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = mapping()

    # translation dict to convert ggplot aes terms to Makie terms

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
                        "alpha" => "alpha",
                        "stack" => "stack",
                        "dodge" => "dodge",
                        "errorbar_direction" => "direction",
                        "text" => "text",
                        "label" => "text")

    # turn the visual function into a layer with the right args

    optional_visual_args = optional_aes

    args_given = intersect(
        keys(optional_visual_args),
        keys(args_dict)
    )

    if isnothing(visual)
        geom_visual = mapping() 
    elseif length(args_given) != 0
        visual_args = Dict(Symbol(optional_visual_args[a]) => args_dict[a] for a in args_given)
        geom_visual = AlgebraOfGraphics.visual(visual; visual_args...)
    else
        geom_visual = AlgebraOfGraphics.visual(visual)
    end  

    # return a geom object

    return Geom(aes_dict, args_dict,
        plot_data, geom_visual, analysis,
        required_aes, optional_aes)

end