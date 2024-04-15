"""
    geom_boxplot(aes(...), ...)
    geom_boxplot(plot::GGPlot, aes(...), ...)

Compactly displays the distribution of continuous data.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.BoxPlot)

# Required Aesthetics

- `x` OR `y`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
geom_boxplot = geom_template("geom_boxplot", ["x", "y"], :BoxPlot)
