macro geom_contour(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_contour"
    
    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Contour, # function for visual layer
        AlgebraOfGraphics.density()) # function for analysis layer

end

macro geom_tile(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_tile"
    
    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Heatmap, # function for visual layer
        AlgebraOfGraphics.density()) # function for analysis layer

end

geom_tile = geom_template("geom_tile", ["x", "y"], Makie.Heatmap, AlgebraOfGraphics.density())
geom_contour = geom_template("geom_contour", ["x", "y"], Makie.Contour, AlgebraOfGraphics.density())