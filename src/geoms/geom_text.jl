"""
    geom_text(aes(...), ...)
    geom_text(plot::GGPlot, aes(...), ...)

Plot text on a graph.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Text)

# Required Aesthetics

- `x`
- `y`
- `text`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
geom_text = geom_template("geom_text", ["x", "y"], :Text;
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(:text => [:text]=>verbatim))

"""
    geom_label(aes(...), ...)
    geom_label(plot::GGPlot, aes(...), ...)

Plot text on a graph.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Text)

# Required Aesthetics

- `x`
- `y`
- `text`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
geom_label = geom_template("geom_label", ["x", "y"], :Text;
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(:text => [:text]=>verbatim))
