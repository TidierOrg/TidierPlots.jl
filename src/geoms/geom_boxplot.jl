"""
    geom_boxplot(aes(...), ...)
    geom_boxplot(plot::GGPlot, aes(...), ...)

Compactly displays the distribution of continuous data.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.BoxPlot)

# Required Aesthetics

- `x` (integer or categorical)
- `y` (numeric)

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (used in conjunction with `dodge`)
- `dodge`

# Optional Arguments

- `orientation=:vertical`: orientation of box (`:vertical` or `:horizontal`)
- `width=1`
- `gap=0.2`
- `show_notch=false`
- `nothchwidth=0.5`
- `show_median=true`
- `dodge_gap=0.03`

# Examples

```julia
ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_boxplot()

ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_boxplot(orientation=:horizontal)

ggplot(penguins, @aes(x=species, y=bill_length_mm, dodge=sex, color=sex)) +
    geom_boxplot()
```
"""
geom_boxplot = geom_template("geom_boxplot", ["x", "y"], :BoxPlot)
