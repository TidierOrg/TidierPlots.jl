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
geom_density = geom_template("geom_density", ["x"], :Density)