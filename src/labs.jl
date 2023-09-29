function labs(plot::GGPlot, args...; kwargs...)
    # there should only be args 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    return plot + args_dict
end

function labs(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    return args_dict
end

function lims(plot::GGPlot, args...; kwargs...)
    # there should only be args 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    lims_dict = Dict()

    if haskey(args_dict, "x")
        if haskey(args_dict, "y")
            lims_dict["limits"] = (
                (args_dict["x"].args[2], args_dict["x"].args[3]),
                (args_dict["y"].args[2], args_dict["y"].args[3])
            )
        else
            lims_dict["limits"] = (
                (args_dict["x"].args[2], args_dict["x"].args[3]),
                nothing
            )
        end
    else
        if haskey(args_dict, "y")
            lims_dict["limits"] = (
                nothing,
                (args_dict["y"].args[2], args_dict["y"].args[3])
            )
        else
            lims_dict["limits"] = (
                nothing,
                nothing
            )
        end
    end

    return plot + lims_dict
end

function lims(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    lims_dict = Dict()

    if haskey(args_dict, "x")
        if haskey(args_dict, "y")
            lims_dict["limits"] = (
                (args_dict["x"][1], args_dict["x"][2]),
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict["limits"] = (
                (args_dict["x"][1], args_dict["x"][2]),
                nothing
            )
        end
    else
        if haskey(args_dict, "y")
            lims_dict["limits"] = (
                nothing,
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict["limits"] = (
                nothing,
                nothing
            )
        end
    end

    return lims_dict
end

