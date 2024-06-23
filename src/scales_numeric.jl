function continuous_scale_to_ggoptions(args_dict::Dict)

    options_dict = Dict()

    if haskey(args_dict, "name")
        options_dict[args_dict["scale"]*"label"] = args_dict["name"]
    end

    if haskey(args_dict, "trans")
        options_dict[args_dict["scale"]*"scale"] = args_dict["trans"]
    end

    if haskey(args_dict, "reversed")
        options_dict[args_dict["scale"]*"reversed"] = args_dict["reversed"]
    end

    if haskey(args_dict, "labels")
        options_dict[Symbol(args_dict["scale"] * "tickformat")] = args_dict["labels"]
    end

    return AxisOptions(
        Dict(Symbol(k) => v for (k, v) in options_dict), Dict(), Dict()
    )

end

# Generator - generates two function signatures

function scale_template(scale, f; trans=nothing, reverse=nothing)
    function scale_function(args...; trans=trans, reverse=reverse, scale=scale, f=f, kwargs...)
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
    function scale_function(plot::GGPlot, args...; trans=trans, reverse=reverse, scale=scale, f=f, kwargs...)
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

scale_x_continuous = scale_template("x", continuous_scale_to_ggoptions)
scale_y_continuous = scale_template("y", continuous_scale_to_ggoptions)
scale_x_log10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log10)
scale_y_log10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log10)
scale_x_reverse = scale_template("x", continuous_scale_to_ggoptions; reverse=true)
scale_y_reverse = scale_template("y", continuous_scale_to_ggoptions; reverse=true)
scale_x_sqrt = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.sqrt)
scale_y_sqrt = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.sqrt)
scale_x_log2 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log2)
scale_y_log2 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log2)
scale_x_log = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log)
scale_y_log = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log)
scale_x_logit = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.logit)
scale_y_logit = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.logit)
scale_x_pseudolog10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.pseudolog10)
scale_y_pseudolog10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.pseudolog10)
scale_x_symlog10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.Symlog10)
scale_y_symlog10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.Symlog10)
