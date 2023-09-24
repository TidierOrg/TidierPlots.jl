macro geom_text(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_text"
    args_dict["text_function"] = AlgebraOfGraphics.verbatim
    args_dict["label_function"] = AlgebraOfGraphics.verbatim

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Text, # function for visual layer
        AlgebraOfGraphics.mapping()) # function for analysis layer

end

macro geom_label(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_label"
    args_dict["text_function"] = AlgebraOfGraphics.verbatim
    args_dict["label_function"] = AlgebraOfGraphics.verbatim

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Text, # function for visual layer
        AlgebraOfGraphics.mapping()) # function for analysis layer

end