macro geom_path(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    return build_geom(aes_dict, args_dict, 
                      ["x", "y"], # required aesthetics
                      Makie.Lines, # function for visual layer
                      mapping()) # function for analysis layer    
end