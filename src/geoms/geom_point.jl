"""
Color and fill work slightly strangely in geom_point in ggplot2. Replicates behaviour.
"""
function handle_point_color_and_fill(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{Any, Any}, required_aes::Vector{String}, plot_data::DataFrame)

    has_color = haskey(aes_dict, :color) || haskey(aes_dict, :colour)
    has_fill = haskey(aes_dict, :fill)

    colorname = !has_color ? nothing :
        haskey(aes_dict, :color) ? :color : :colour

    if !has_fill
        return (aes_dict, args_dict, required_aes, plot_data)
    else
        if !has_color
            aes_dict[:color] = aes_dict[:fill]
        else
            aes_dict[:strokecolor] = aes_dict[colorname]
            aes_dict[colorname] = aes_dict[:fill]
        end
    end

    delete!(aes_dict, :fill)

    return (aes_dict, args_dict, required_aes, plot_data)
end


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
geom_point = geom_template("geom_point", ["x", "y"], :Scatter;
    pre_function = handle_point_color_and_fill)
