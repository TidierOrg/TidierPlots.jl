"""
    geom_point(aes(...), ...)
    geom_point(plot::GGPlot, aes(...), ...)

Represents data as pairs of (x, y) points.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Scatter)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See aes() for specification options)

- size
- alpha
- stroke
- shape
- colour/color

# Supported Options

TBD
"""
geom_point = geom_template("geom_point", ["x", "y"], :Scatter)
