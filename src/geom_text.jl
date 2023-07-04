macro geom_text(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_text"

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Annotations, # function for visual layer
        AlgebraOfGraphics.mapping()) # function for analysis layer

end

macro geom_label(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_label"

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Annotations, # function for visual layer
        AlgebraOfGraphics.mapping()) # function for analysis layer

end