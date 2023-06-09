macro labs(exprs...)
    # there should only be args 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    return GGOptions(args_dict)
end

macro lims(exprs...)
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


    return GGOptions(lims_dict)
end

