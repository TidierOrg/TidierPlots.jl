"""
    geom_density(aes(...), ...)
    geom_density(plot::GGPlot, aes(...), ...)

Represent data as a smooth density curve.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame and their corresponding aesthetic.
- `...`: options that are not mapped to a column (passed to Makie.Density)

# Required Aesthetics

- `x`

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
