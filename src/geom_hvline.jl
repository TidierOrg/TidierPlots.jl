macro geom_hline(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_hline"

    return build_geom(aes_dict, args_dict, 
        ["yintercept"], # required aesthetics
        Makie.HLines, # function for visual layer
        mapping()) # function for analysis layer    
end

macro geom_vline(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_vline"

    return build_geom(aes_dict, args_dict, 
        ["yintercept"], # required aesthetics
        Makie.VLines, # function for visual layer
        mapping()) # function for analysis layer    
end