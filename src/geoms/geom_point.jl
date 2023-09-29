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
geom_point = geom_template("geom_point", ["x", "y"], Makie.Scatter, mapping())