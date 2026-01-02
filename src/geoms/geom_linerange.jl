"""
    geom_linerange(aes(...), ...)
    geom_linerange(plot::GGPlot, aes(...), ...)

Displays a vertical line from ymin to ymax (without whiskers).

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# Required Aesthetics

- `x`
- `ymin`
- `ymax`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `linewidth`
- `alpha`

# Examples

```julia
df = DataFrame(
    x = [1, 2, 3, 4],
    ymin = [1, 2, 1.5, 2.5],
    ymax = [3, 4, 3.5, 4.5]
)

ggplot(df, @aes(x = x, ymin = ymin, ymax = ymax)) + geom_linerange()
```
"""
geom_linerange = geom_template("geom_linerange", ["x", "ymin", "ymax"], :Rangebars;
    grouping_aes = [:color, :colour])
