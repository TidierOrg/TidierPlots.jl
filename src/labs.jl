function labs(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    ggplot_to_makie = Dict(
        "title" => :title,
        "x" => :xlabel,
        "y" => :ylabel,
        "subtitle" => :subtitle
    )

    return AxisOptions(Dict(ggplot_to_makie[k] => v for (k, v) in args_dict))
end

function labs(plot::GGPlot, args...; kwargs...)
    return plot + labs(args...; kwargs...)
end

function lims(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    lims_dict = Dict{Symbol, Any}()

    if haskey(args_dict, "x")
        if haskey(args_dict, "y")
            lims_dict[:limits] = (
                (args_dict["x"][1], args_dict["x"][2]),
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict[:limits] = (
                (args_dict["x"][1], args_dict["x"][2]),
                nothing
            )
        end
    else
        if haskey(args_dict, "y")
            lims_dict[:limits] = (
                nothing,
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict[:limits] = (
                nothing,
                nothing
            )
        end
    end

    return AxisOptions(lims_dict)
end

function lims(plot::GGPlot, args...; kwargs...)
    return plot + lims(args...; kwargs...)
end
