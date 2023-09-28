macro geom_smooth(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    args_dict["geom_name"] = "geom_smooth"
    
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

function geom_smooth(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_smooth"
    
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
