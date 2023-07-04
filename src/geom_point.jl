macro geom_point(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_point"

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Scatter, # function for visual layer
        mapping()) # function for analysis layer    
end