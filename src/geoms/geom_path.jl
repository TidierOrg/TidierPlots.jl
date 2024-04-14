"""
    geom_line(aes(...), ...)
    geom_line(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order of the variable on the x-axis.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
geom_line = geom_template("geom_line", ["x", "y"], :Lines)

"""
    geom_step(aes(...), ...)
    geom_step(plot::GGPlot, aes(...), ...)

Represents data as a stairstep plot.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Stairs)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
geom_step = geom_template("geom_step", ["x", "y"], :Stairs)

"""
    geom_path(aes(...), ...)
    geom_path(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order in which they appear in the data.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
geom_path = geom_template("geom_path", ["x", "y"], :Lines)
