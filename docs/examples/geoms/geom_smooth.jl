# # geom_smooth

# Aids the eye in seeing patterns in the presence of overplotting by adding smoothed conditional means. `geom_smooth()` fits a model to the data and displays the fitted line along with a confidence interval (for linear models). This is particularly useful when you have many data points and want to visualize the underlying trend.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Lines)

# ## Smoothing Methods

# TidierPlots supports two smoothing methods:
# - `method="smooth"` (default): Uses LOESS (locally estimated scatterplot smoothing), which fits local polynomial regressions. This is flexible and follows the data closely.
# - `method="lm"`: Uses linear regression, fitting a straight line through the data. This also displays a 95% confidence band around the line.

# ## Required Aesthetics

# - `x`
# - `y`

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`
# - `group`

# ## Optional Arguments

# - `method`: "smooth" (default, LOESS) or "lm" (linear regression)
# - `color` / `colour`: line color
# - `linewidth`: line thickness
# - `alpha`: transparency
# - `linestyle` / `linetype`: line pattern

using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

# ## Basic LOESS Smoothing

# The default method is LOESS (locally estimated scatterplot smoothing), which creates a flexible smooth line that follows the data:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.3) +
    geom_smooth()

# Combine smooth line with points for context:

xs = range(0, 2pi, length = 50)
ys = sin.(xs) .+ randn(length(xs)) * 0.3
df = DataFrame(x = xs, y = ys)

ggplot(df, @aes(x = x, y = y)) +
    geom_point() +
    geom_smooth()

# ## Linear Regression

# Use `method="lm"` for linear regression. This displays both the fitted line and a 95% confidence band:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "lm")

# ## Customizing Appearance

# Change the color and line width:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.3) +
    geom_smooth(color = :red, linewidth = 3, alpha = 0.7)

# Use line styles:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.3) +
    geom_smooth(linestyle = :dash, linewidth = 2)

# ## Grouping

# The smooth line respects the `color` aesthetic, fitting separate curves for each group:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
    geom_point(alpha = 0.3) +
    geom_smooth()

# With linear regression by group:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "lm")

# ## Comparing Methods

# Compare LOESS and linear regression on the same plot:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.2) +
    geom_smooth(color = :blue, linewidth = 2) +
    geom_smooth(method = "lm", color = :red, linewidth = 2, linestyle = :dash)

# ## Using with Facets

# Smooth lines work well with faceting to show trends in subgroups:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "lm") +
    facet_wrap(:species)

# ## Handling Noisy Data

# LOESS smoothing is particularly useful for visualizing trends in noisy data:

noisy_df = DataFrame(
    x = 1:100,
    y = sin.((1:100) ./ 10) .+ randn(100) .* 0.5
)

ggplot(noisy_df, @aes(x = x, y = y)) +
    geom_point(alpha = 0.5) +
    geom_smooth(color = :red, linewidth = 2)
