"""
    geom_density(aes(...), ...)
    geom_density(plot::GGPlot, aes(...), ...)

Represent data as a smooth density curve.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Density)

# Required Aesthetics

- `x`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `strokecolor` / `strokecolour`
- `strokewidth` / `stroke`
- `linestyle` / `linetype`
- `direction=:x`
- `npoints=200`

# Examples

```julia
ggplot(penguins, @aes(x=bill_length_mm)) + geom_density()

ggplot(penguins, @aes(x=bill_length_mm)) +
    geom_density(color = (:red, 0.3), strokecolor = :red, stroke = 2)
```
"""
geom_density = geom_template("geom_density", ["x"], :Density; grouping_aes = [:color, :colour])
