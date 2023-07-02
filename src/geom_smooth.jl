macro geom_smooth(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    analysis = AlgebraOfGraphics.smooth()

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear()
        end
    end
    
    return build_geom(aes_dict, args_dict, 
                      ["x", "y"], # required aesthetics
                      nothing, # function for visual layer
                      analysis) # function for analysis layer
end