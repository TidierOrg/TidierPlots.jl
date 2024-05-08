"""
    geom_histogram(aes(...), ...)
    geom_histogram(plot::GGPlot, aes(...), ...)

Represents data as a histogram.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Hist)

# Required Aesthetics

- `x`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `bins`
- `normalization`
- `color` / `colour`
- `stroke` / `strokewidth`
- `strokecolor` / `strokecolour`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram()

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization=:probability, bins=20)
```
"""
geom_histogram = geom_template("geom_histogram", ["x"], :Hist; 
    grouping_aes = [:color, :colour])
