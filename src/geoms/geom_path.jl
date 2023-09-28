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
                      Makie.Lines, # function for visual layer
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

geom_line = geom_template("geom_line", ["x", "y"], Makie.Lines, mapping())
geom_step = geom_template("geom_step", ["x", "y"], Makie.Stairs, mapping())
geom_path = geom_template("geom_path", ["x", "y"], Makie.Lines, mapping())