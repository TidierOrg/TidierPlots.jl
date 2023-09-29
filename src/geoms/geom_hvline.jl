function geom_hline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_hline"

    return build_geom(aes_dict, args_dict, 
        ["yintercept"], # required aesthetics
        Makie.HLines, # function for visual layer
        mapping()) # function for analysis layer    
end

function geom_vline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_vline"

    return build_geom(aes_dict, args_dict, 
        ["xintercept"], # required aesthetics
        Makie.VLines, # function for visual layer
        mapping()) # function for analysis layer    
end

function geom_hline(plot::GGPlot, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_hline"

    return plot + build_geom(aes_dict, args_dict, 
        ["yintercept"], # required aesthetics
        Makie.HLines, # function for visual layer
        mapping()) # function for analysis layer    
end

function geom_vline(plot::GGPlot, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    args_dict["geom_name"] = "geom_vline"

    return plot + build_geom(aes_dict, args_dict, 
        ["xintercept"], # required aesthetics
        Makie.VLines, # function for visual layer
        mapping()) # function for analysis layer    
end