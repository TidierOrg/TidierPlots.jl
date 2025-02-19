"""
    geom_rainclouds(aes(...), ...)
    geom_rainclouds(plot::GGPlot, aes(...), ...)

"Raincloud" plots are a combination of a (half) violin plot, box plot and scatter plots. The three together can make an appealing and informative visual, particularly for large N datasets.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
- `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `inherit_aes`: should the geom inherit aes from the ggplot?
- `...`: options that are not mapped to a column (passed to Makie.RainClouds)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `size`
- `stroke`
- `dodge`

# Optional Arguments

- `boxplot_nudge`: Default 0.075. Determines the distance away the boxplot should be placed from the center line when center_boxplot is false. This is the value used to recentering the boxplot.
- `boxplot_width`: Default 0.1. Determines the width of the boxplot.
- `center_boxplot`: Default true. Determines whether the boxplot should be centered on the category.
- `cloud_width`: Default 0.75. Determines the width of the violin.
- `clouds`: Default violin. Valid values: [violin, hist, nothing]clouds
- `color` / `colour`: Default will be blue unless changed by palette or aes.
- `dodge_gap`: Default 0.01. Determines the gap between the dodged boxes.
- `gap`: Default 0.2. Distance between the main elements of the plot.
- `hist_bins`: Default 30. If `clouds == hist`, determines the number of bins for the histogram.
- `markersize` / `size`: Default 2. Size of markers in the scatterplot.
- `plot_boxplots`: Default true. Determines whether the boxplot should be plotted.
- `show_boxplot_outliers`: Default false. Determines whether the outliers should be shown in the boxplot.
- `show_median`: Default true. Determines whether the median should be shown in the boxplot.
- `side`: Default :left. Determines the side of the violin relative to the points.
- `strokewidth` / `stroke`: Default 1. Width of the stroke around the boxplot.
- `whisker_width`: Default 0.5. Width of the whiskers in the boxplot.

# Examples

```julia
ggplot(penguins) +
    geom_rainclouds(@aes(x = species, y = bill_depth_mm/10, color = species), size = 5) +
    scale_y_continuous(labels = "{:.1f} cm") +
    labs(title = "Bill Depth by Species", x = "Species", y = "Bill Depth") +
    theme_minimal()
```
"""
geom_rainclouds = geom_template("geom_rainclouds", ["x", "y"], :RainClouds,
    pre_function=boxplot_groups,
    special_aes=Dict(
        :fill => :color,
        :colour => :color
    ))
