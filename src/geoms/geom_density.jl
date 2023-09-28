"""
    @geom_density(aes(...), ...)
    
    Represent data as a smooth density curve. 

    # Arguments

    - `aes(...)`: the names of the columns in the plot DataFrame and their corresponding aesthetic.
    - `...`: options that are not mapped to a column 

    # Required Aesthetics

    - x

    # Supported Optional Aesthetics

    - alpha
    - stroke
    - colour/color

    # Supported Options

    - alpha
    - stroke
    - colour/color

"""
macro geom_density(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_density"

    return build_geom(aes_dict, args_dict, 
        ["x"], # required aesthetics
        nothing, # function for visual layer
        AlgebraOfGraphics.density()) # function for analysis layer    
end

geom_density = geom_template("geom_density", ["x"], nothing, AlgebraOfGraphics.density())