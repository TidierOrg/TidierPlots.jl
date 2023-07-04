macro geom_path(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_path"

    return build_geom(aes_dict, args_dict, 
                      ["x", "y"], # required aesthetics
                      Makie.Lines, # function for visual layer
                      mapping()) # function for analysis layer    
end

macro geom_line(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_line"

    return build_geom(aes_dict, args_dict, 
                      ["x", "y"], # required aesthetics
                      Makie.Series, # function for visual layer
                      mapping()) # function for analysis layer    
end

macro geom_step(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_step"

    return build_geom(aes_dict, args_dict, 
                      ["x", "y"], # required aesthetics
                      Makie.Stairs, # function for visual layer
                      mapping()) # function for analysis layer    
end