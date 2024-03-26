function geom_hline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_hline"

    if haskey(args_dict, "yintercept")
        args_dict["data"] = DataFrame(Numeric = args_dict["yintercept"])
        aes_dict["yintercept"] = :Numeric
    end

    return build_geom(aes_dict, args_dict, 
        ["yintercept"], # required aesthetics
        :HLines,
        do_nothing, Dict{Symbol, Function}()) # function for visual layer  
end

function geom_vline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_vline"

    if haskey(args_dict, "xintercept")
        args_dict["data"] = DataFrame(Numeric = args_dict["xintercept"])
        aes_dict["xintercept"] = :Numeric
    end

    return build_geom(aes_dict, args_dict, 
        ["xintercept"], # required aesthetics
        :VLines,
        do_nothing, Dict{Symbol, Function}()) # function for visual layer   
end

function geom_hline(plot::GGPlot, args...; kwargs...)
    return plot + geom_hline(args...; kwargs...) 
end

function geom_vline(plot::GGPlot, args...; kwargs...)
    return plot + geom_vline(args...; kwargs...)   
end