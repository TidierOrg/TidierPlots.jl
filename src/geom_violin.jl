macro geom_violin(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_violin"
    
    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Violin, # function for visual layer
        AlgebraOfGraphics.mapping()) # function for analysis layer

end