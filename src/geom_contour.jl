macro geom_contour(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Contour, # function for visual layer
        AlgebraOfGraphics.density()) # function for analysis layer

end

macro geom_tile(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Heatmap, # function for visual layer
        AlgebraOfGraphics.density()) # function for analysis layer

end