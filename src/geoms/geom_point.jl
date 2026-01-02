"""
Color and fill work slightly strangely in geom_point in ggplot2. Replicates behaviour.

In ggplot2:
- fill = interior color of the point
- color/colour = border (stroke) color of the point

In Makie Scatter:
- color = interior color
- strokecolor = border color

This function translates between the two conventions for both:
- aes_dict: aesthetics mapped to data columns
- args_dict: static values passed as arguments
"""
function handle_point_color_and_fill(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{Any,Any}, required_aes::Vector{String}, plot_data::DataFrame)

    # Check for color/fill in aes_dict (mapped to data columns)
    has_aes_color = haskey(aes_dict, :color) || haskey(aes_dict, :colour)
    has_aes_fill = haskey(aes_dict, :fill)

    # Check for color/fill in args_dict (static values)
    has_arg_color = haskey(args_dict, "color") || haskey(args_dict, "colour")
    has_arg_fill = haskey(args_dict, "fill")

    # Handle aes_dict (mapped aesthetics)
    if has_aes_fill
        colorname = !has_aes_color ? nothing :
                    haskey(aes_dict, :color) ? :color : :colour

        if !has_aes_color
            aes_dict[:color] = aes_dict[:fill]
        else
            aes_dict[:strokecolor] = aes_dict[colorname]
            aes_dict[colorname] = aes_dict[:fill]
        end
        delete!(aes_dict, :fill)
    end

    # Handle args_dict (static values)
    if has_arg_fill
        arg_colorname = !has_arg_color ? nothing :
                        haskey(args_dict, "color") ? "color" : "colour"

        fill_value = args_dict["fill"]

        if !has_arg_color
            # fill only: use fill as interior color
            args_dict["color"] = fill_value
        else
            # both fill and color: fill is interior, color becomes stroke
            args_dict["strokecolor"] = args_dict[arg_colorname]
            args_dict[arg_colorname] = fill_value
        end
        delete!(args_dict, "fill")
    end

    return (aes_dict, args_dict, required_aes, plot_data)
end


"""
    geom_point(aes(...), ...)
    geom_point(plot::GGPlot, aes(...), ...)

The point geom is used to create scatterplots. The scatterplot is most useful for displaying the relationship between two continuous variables. It can be used to compare one continuous and one categorical variable, or two categorical variables, but other charts are usually more appropriate. A bubblechart is a scatterplot with a third variable mapped to the size of points.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
- `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `inherit_aes`: should the geom inherit aes from the ggplot?
- `...`: options that are not mapped to a column (passed to Makie.Scatter)

# Overplotting

The biggest potential problem with a scatterplot is overplotting: whenever you have more than a few points, points may be plotted on top of one another. This can severely distort the visual appearance of the plot. There is no one solution to this problem, but there are some techniques that can help. You can add additional information with geom_smooth(), or if you have few unique x values, geom_boxplot() may also be useful. Another technique is to make the points transparent (e.g. geom_point(alpha = 0.05)) or very small (e.g. geom_point(shape = '.')).

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `fill`
- `shape`
- `size`
- `stroke`

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
p = ggplot(penguins, @aes(bill_length_mm, bill_depth_mm))
p + geom_point()

# add aesthetic mappings
p + geom_point(aes(colour = :sex))
```
"""
geom_point = geom_template("geom_point", ["x", "y"], :Scatter;
    pre_function=handle_point_color_and_fill)
