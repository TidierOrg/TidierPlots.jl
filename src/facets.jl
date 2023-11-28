function facet_grid(plot::GGPlot, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
 
    if haskey(args_dict, "data")
        aes_dict["row"] = args_dict["rows"]
    end

    if haskey(args_dict, "rows")
        aes_dict["row"] = args_dict["rows"]
    end

    if haskey(args_dict, "cols")
        aes_dict["col"] = args_dict["cols"]
    end
    
    return plot + Aesthetics(aes_dict)
end

function facet_grid(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
 
    if haskey(args_dict, "data")
        aes_dict["row"] = args_dict["rows"]
    end

    if haskey(args_dict, "rows")
        aes_dict["row"] = args_dict["rows"]
    end

    if haskey(args_dict, "cols")
        aes_dict["col"] = args_dict["cols"]
    end
    
    return Aesthetics(aes_dict)
end

function facet_wrap(plot::GGPlot, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if haskey(args_dict, "data")
        aes_dict["layout"] = args_dict["data"]
    end

    if haskey(args_dict, "facets")
        aes_dict["layout"] = args_dict["facets"]
    end
    
    return plot + Aesthetics(aes_dict)
end

function facet_wrap(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if haskey(args_dict, "data")
        aes_dict["layout"] = args_dict["data"]
    end

    if haskey(args_dict, "facets")
        aes_dict["layout"] = args_dict["facets"]
    end
    
    return Aesthetics(aes_dict)
end