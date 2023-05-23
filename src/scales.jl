function to_ggoptions(args_dict::Dict)
    
    options_dict = Dict()
    
    if haskey(args_dict, "name")
        options_dict[args_dict["scale"]] = args_dict["name"]
    end

    if haskey(args_dict, "trans")
        if args_dict["scale"] == "x"
            options_dict["xscale"] = args_dict["trans"]
        elseif args_dict["scale"] == "y"
            options_dict["yscale"] = args_dict["trans"]
        end
    end

    if haskey(args_dict, "xreversed")
        options_dict["xreversed"] = true
    end

    if haskey(args_dict, "yreversed") 
        options_dict["yreversed"] = true
    end

    return(GGOptions(options_dict))

end

macro scale_x_continuous(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "x"
    return to_ggoptions(args_dict)
end

macro scale_y_continuous(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "y"
    return to_ggoptions(args_dict)
end

macro scale_x_log10(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "x"
    args_dict["trans"] = AlgebraOfGraphics.log10
    return to_ggoptions(args_dict)
end

macro scale_y_log10(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "y"
    args_dict["trans"] = AlgebraOfGraphics.log10
    return to_ggoptions(args_dict)
end

macro scale_x_reverse(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "x"
    args_dict["xreversed"] = true 
    return to_ggoptions(args_dict)
end

macro scale_y_reverse(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "y"
    args_dict["yreversed"] = true 
    return to_ggoptions(args_dict)
end

macro scale_x_sqrt(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "x"
    args_dict["trans"] = AlgebraOfGraphics.sqrt
    return to_ggoptions(args_dict)
end

macro scale_y_sqrt(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    args_dict["scale"] = "y"
    args_dict["trans"] = AlgebraOfGraphics.sqrt
    return to_ggoptions(args_dict)
end