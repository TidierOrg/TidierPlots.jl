# # geom_hline and geom_vline

# These geoms add reference lines to a plot: `geom_hline()` adds horizontal lines and `geom_vline()` adds vertical lines. Reference lines are useful for marking thresholds, means, or other important values. Unlike most other geoms, these do not inherit x and y aesthetics from the plot, and they do not affect the x and y scales.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `...`: options that are not mapped to a column (passed to Makie.HLines or Makie.VLines)

# ## Specifying Line Positions

# Line positions can be specified in two ways:
# 1. As a fixed value using the `yintercept` or `xintercept` argument (for a single line or multiple lines)
# 2. As an aesthetic mapping to a column in the data (allows different lines in different facets)

# ## Required Aesthetics

# For `geom_hline()`:
# - `yintercept` (can be supplied as argument or aesthetic)

# For `geom_vline()`:
# - `xintercept` (can be supplied as argument or aesthetic)

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`

# ## Optional Arguments

# - `yintercept` (geom_hline): y-value(s) for horizontal line(s)
# - `xintercept` (geom_vline): x-value(s) for vertical line(s)
# - `color` / `colour`: line color
# - `linewidth`: line thickness
# - `linestyle` / `linetype`: line pattern (e.g., `:dash`, `:dot`, `:dashdot`)
# - `colormap` / `palette`
# - `alpha`

using TidierPlots
using TidierData
using DataFrames
using Parquet2

penguins = DataFrame(Parquet2.readfile(joinpath("penguins.parq")))

# ## Horizontal Lines

# Add a single horizontal line at a specific y-value:

ggplot() +
    geom_hline(yintercept = 3)

# Add a horizontal line to an existing plot:

ggplot(penguins) +
    geom_point(@aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_hline(yintercept = 17, color = :red, linewidth = 2)

# Add the mean as a reference line:

mean_depth = sum(penguins.bill_depth_mm)/nrow(penguins)

ggplot(penguins) +
    geom_point(@aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_hline(yintercept = mean_depth, color = :blue, linewidth = 2, linestyle = :dash)

# Add multiple horizontal lines:

ggplot() +
    geom_hline(yintercept = [-1, 0, 1, 4], linewidth = 1)

# Map yintercept to a column in the data:

df = DataFrame(y = [1, 2, 3, 4])
ggplot(df, @aes(yintercept = y)) +
    geom_hline(color = :steelblue, linewidth = 2)

# ## Vertical Lines

# Add a single vertical line:

ggplot() +
    geom_vline(xintercept = 3)

# Add a vertical line to highlight a specific x-value:

ggplot(penguins) +
    geom_point(@aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_vline(xintercept = 45, color = :red, linewidth = 2, linestyle = :dash)

# Add multiple vertical lines:

ggplot() +
    geom_vline(xintercept = [-1, 0, 4], color = :purple, linewidth = 1)

# Map xintercept to a column:

df = DataFrame(x = [1, 2, 3, 4])
ggplot(df, @aes(xintercept = x)) +
    geom_vline(color = :orange, linewidth = 2)

# ## Combining Both

# Use both horizontal and vertical lines together to create reference grids or mark important points:

ggplot(penguins) +
    geom_point(@aes(x = bill_length_mm, y = bill_depth_mm), alpha = 0.5) +
    geom_hline(yintercept = sum(penguins.bill_depth_mm)/nrow(penguins), color = :blue, linestyle = :dash) +
    geom_vline(xintercept = sum(penguins.bill_length_mm)/nrow(penguins), color = :red, linestyle = :dash)

# Different line styles:

ggplot(penguins) +
    geom_point(@aes(x = bill_length_mm, y = bill_depth_mm), alpha = 0.3) +
    geom_hline(yintercept = 15, linestyle = :solid, color = :black) +
    geom_hline(yintercept = 17, linestyle = :dash, color = :red) +
    geom_hline(yintercept = 19, linestyle = :dot, color = :blue) +
    geom_hline(yintercept = 21, linestyle = :dashdot, color = :green)
