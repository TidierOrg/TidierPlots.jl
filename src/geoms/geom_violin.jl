"""
    geom_(aes(...), ...)
    geom_(plot::GGPlot, aes(...), ...)

Represents data as a violin plot.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Violin)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
geom_violin = geom_template("geom_violin", ["x", "y"], :Violin)
