function continuous_scale_to_ggoptions(args_dict::Dict)
    
    options_dict = Dict()
    
    if haskey(args_dict, "name")
        options_dict[args_dict["scale"]] = args_dict["name"]
    end

    if haskey(args_dict, "trans")
        options_dict[args_dict["scale"] * "scale"] = args_dict["trans"]
    end

    if haskey(args_dict, "reversed")
        options_dict[args_dict["scale"] * "reversed"] = args_dict["reversed"]
    end

    return AxisOptions(options_dict) 

end

function colour_scale_to_ggoptions(args_dict::Dict)
    
    options_dict = Dict()

    if args_dict["scale"] == "colour_discrete"
        if haskey(args_dict, "palette")
            options_dict["palettes"] = Symbol(args_dict["palette"])
            options_dict["color_palette_type"] = "discrete"
        end
    elseif args_dict["scale"] == "colour_manual"
        if haskey(args_dict, "values")
            v = args_dict["values"]
            if v isa Expr
                v = [value for value in v.args[2:end]]
            end  
            colors = (x -> parse(Colors.Colorant, x)).(v)
            options_dict["palettes"] = (color = colors,)
            options_dict["color_palette_type"] = "manual"
        end
    elseif args_dict["scale"] == "colour_continuous"
        if haskey(args_dict, "palette")
            options_dict["colormap"] = Symbol(args_dict["palette"])
            options_dict["color_palette_type"] = "continuous"
        end
    end

    return AxisOptions(options_dict) 
end

# Generator - generates two function signatures

function scale_template(scale, f; trans = nothing, reverse = nothing)
    function scale_function(args...; kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        if !isnothing(scale) 
            args_dict["scale"] = scale
        end
        if !isnothing(trans) 
            args_dict["trans"] = trans
        end
        if !isnothing(reverse)
            args_dict["reversed"] = reverse
        end
        
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        if !isnothing(scale) 
            args_dict["scale"] = scale
        end
        if !isnothing(trans) 
            args_dict["trans"] = trans
        end
        if !isnothing(reverse)
            args_dict["reversed"] = reverse
        end
        
        return plot + f(args_dict)
    end
    return scale_function
end

# Definitions

scale_colour_manual = scale_template("colour_manual", colour_scale_to_ggoptions)
scale_color_manual = scale_template("colour_manual", colour_scale_to_ggoptions)
scale_colour_discrete = scale_template("colour_discrete", colour_scale_to_ggoptions)
scale_color_discrete = scale_template("colour_discrete", colour_scale_to_ggoptions)
scale_colour_continuous = scale_template("colour_continuous", colour_scale_to_ggoptions)
scale_color_continuous = scale_template("colour_continuous", colour_scale_to_ggoptions)

scale_x_continuous = scale_template("x", continuous_scale_to_ggoptions)
scale_y_continuous = scale_template("y", continuous_scale_to_ggoptions)
scale_x_log10 = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.log10)
scale_y_log10 = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.log10)
scale_x_reverse = scale_template("x", continuous_scale_to_ggoptions; reverse = true)
scale_y_reverse = scale_template("y", continuous_scale_to_ggoptions; reverse = true)
scale_x_sqrt = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.sqrt)
scale_y_sqrt = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.sqrt)
scale_x_log2 = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.log2)
scale_y_log2 = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.log2)
scale_x_log = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.log)
scale_y_log = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.log)
scale_x_logit = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.logit)
scale_y_logit = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.logit)
scale_x_pseudolog10 = scale_template("x", continuous_scale_to_ggoptions; trans = Makie.pseudolog10)
scale_y_pseudolog10 = scale_template("y", continuous_scale_to_ggoptions; trans = Makie.pseudolog10)
