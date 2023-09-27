function build_geom(aes_dict, args_dict, required_aes, visual, analysis; special_aes = nothing)
    
    # if data is specified, call a questionable eval to grab it as a layer

    if haskey(args_dict, "data")
        # if the code is running in a Pluto.jl notebook
        if !isnothing(match(r"#==#", @__FILE__))
            plot_data = AlgebraOfGraphics.data(eval(args_dict["data"]))
        else
            plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"]))
        end
    else
        plot_data = mapping()
    end

    # translation dict to convert ggplot aes terms to Makie terms

    optional_aes = Dict("color" => "color",
                        "colour" => "color",
                        "shape" => "marker",
                        "size" => "markersize",
                        "stroke" => "strokewidth",
                        "strokecolor" => "strokecolor",
                        "strokecolour" => "strokecolor",
                        "linetype" => "linestyle",
                        "glow" => "glowwidth",
                        "glowcolor" => "glowcolor",
                        "glowcolour" => "glowcolor",
                        "alpha" => "alpha",
                        "stack" => "stack",
                        "dodge" => "dodge",
                        "errorbar_direction" => "direction",
                        "text" => "text",
                        "label" => "text",
                        "row" => "row",
                        "col" => "col", 
                        "layout" => "layout")

    if !isnothing(special_aes)
        optional_aes = merge(optional_aes, special_aes)
    end

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
        required_aes, optional_aes, Dict())

end