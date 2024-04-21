"""
    geom_point(aes(...), ...)
    geom_point(plot::GGPlot, aes(...), ...)

Represents data as pairs of (x, y) points.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Scatter)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `color`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `marker` / `shape`
- `markersize` / `size`
- `strokewidth` / `stroke`
- `strokecolor` / `strokecolour`
- `glowwidth` / `glow`
- `glowcolor` / `glowcolour`
- `alpha`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point()

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(color = sex), size=20, stroke=1, alpha=0.6)
```
"""
geom_point = geom_template("geom_point", ["x", "y"], :Scatter)
