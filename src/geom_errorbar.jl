macro geom_errorbar(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_errorbar"
    
    return build_geom(aes_dict, args_dict, 
        ["x", "ymin", "ymax"], # required aesthetics
        Makie.Rangebars, # function for visual layer
        AlgebraOfGraphics.mapping(), # function for analysis layer
        special_aes = Dict("width" => "whiskerwidth")) 
end

macro geom_errorbarh(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_errorbarh"
    args_dict["errorbar_direction"] = :x

    return build_geom(aes_dict, args_dict, 
        ["y", "xmin", "xmax"], # required aesthetics
        Makie.Rangebars, # function for visual layer
        AlgebraOfGraphics.mapping(), # function for analysis layer
        special_aes = Dict("width" => "whiskerwidth")) 

end