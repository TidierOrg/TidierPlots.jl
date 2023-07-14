"""
    @geom_point(aes(...), ...)
    
    Represent data as points. 

    # Arguments

    - `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
    - `...`: options that are not mapped to a column 

    # Required Aesthetics

    - x
    - y

    # Supported Optional Aesthetics

    - size
    - alpha
    - stroke
    - shape
    - colour/color

    # Supported Options

    - size
    - alpha
    - stroke
    - shape
    - colour/color

"""
macro geom_point(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))
    
    args_dict["geom_name"] = "geom_point"

    return build_geom(aes_dict, args_dict, 
        ["x", "y"], # required aesthetics
        Makie.Scatter, # function for visual layer
        mapping()) # function for analysis layer    
end