"""
    geom_pointrange(aes(...), ...)
    geom_pointrange(plot::GGPlot, aes(...), ...)

Displays a point with a vertical line from ymin to ymax.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column

# Required Aesthetics

- `x`
- `y`
- `ymin`
- `ymax`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `linewidth`
- `size` / `markersize`
- `alpha`

# Examples

```julia
df = DataFrame(
    x = [1, 2, 3, 4],
    y = [2, 3, 2.5, 3.5],
    ymin = [1, 2, 1.5, 2.5],
    ymax = [3, 4, 3.5, 4.5]
)

ggplot(df, @aes(x = x, y = y, ymin = ymin, ymax = ymax)) + geom_pointrange()
```
"""
function geom_pointrange(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    args_dict["geom_name"] = "geom_pointrange"

    # Return two geoms: rangebars for the lines, scatter for the points
    return [
        build_geom(aes_dict, args_dict,
            ["x", "ymin", "ymax"],
            :Rangebars;
            grouping_aes = [:color, :colour]),
        build_geom(aes_dict, args_dict,
            ["x", "y"],
            :Scatter;
            grouping_aes = [:color, :colour])
    ]
end

function geom_pointrange(plot::GGPlot, args...; kwargs...)
    return plot + geom_pointrange(args...; kwargs...)
end
