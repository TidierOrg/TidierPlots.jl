function stat_sort_by_x(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T, Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    perm = sortperm(plot_data[!, :x])

    return (aes_dict, args_dict, required_aes, plot_data[perm, :])
end

"""
    geom_line(aes(...), ...)
    geom_line(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order of the variable on the x-axis.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_line()
```
"""
geom_line = geom_template("geom_line", ["x", "y"], :Lines;
    post_function = stat_sort_by_x,
    grouping_aes = [:color, :colour]
)


"""
    geom_step(aes(...), ...)
    geom_step(plot::GGPlot, aes(...), ...)

Represents data as a stairstep plot.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Stairs)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_step()
```
"""
geom_step = geom_template("geom_step", ["x", "y"], :Stairs;
    post_function = stat_sort_by_x,
    grouping_aes = [:color, :colour]
)


"""
    geom_path(aes(...), ...)
    geom_path(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order in which they appear in the data.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path()
```
"""
geom_path = geom_template("geom_path", ["x", "y"], :Lines;
    grouping_aes = [:color, :colour])
