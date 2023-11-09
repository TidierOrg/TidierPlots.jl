"""
    geom_smooth(aes(...), ...)
    geom_smooth(plot::GGPlot, aes(...), ...)
    
    Represent data as a smoothed or linear fit. 

    # Arguments

    - `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
    - `...`: options that are not mapped to a column 

    # Required Aesthetics

    - x
    - y

    # Supported Optional Aesthetics

    - alpha
    - colour/color

    # Supported Options

    - method: "smooth" (loess fit) or "lm" (linear fit)
    - alpha
    - colour/color

"""
function geom_smooth(plot::GGPlot, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_smooth"
    
    analysis = AlgebraOfGraphics.smooth()

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear()
        end
    end
    
    return plot + build_geom(aes_dict, args_dict, 
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
