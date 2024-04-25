function stat_density_2d(aes_dict::Dict{String, Symbol},
    args_dict, required_aes::Vector{String}, plot_data::DataFrame)

    new_required_aes = ["x", "y", "z"]

    aes_dict["z"] = :z

    return (aes_dict, args_dict, new_required_aes, plot_data)
end

"""
    geom_contour(aes(...), ...)
    geom_contour(plot::GGPlot, aes(...), ...)

Represents a grid of data as smooth curves of a surface.

# Details

This is geom is equivalent to `ggplot2::ggplot(df, aes(x, y, z = density))`. Only the `x`
and `y` aesthetics are required.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Contour)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `levels`
- `linewidth`
- `linestyle` / `linetype`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_contour(levels = 10)
```
"""
geom_contour = geom_template("geom_contour", ["x", "y"], :Contour;
    aes_function = stat_density_2d,
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(
        :x => [:x]=>discard,
        :y => [:y]=>discard,
        :z => [:x, :y]=>kernel_density_2d))
