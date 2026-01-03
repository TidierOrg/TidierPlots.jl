# # geom_bar

# There are two types of bar charts: `geom_bar()` and `geom_col()`. `geom_bar()` makes the height of the bar proportional to the number of cases in each group (or if the `weight` aesthetic is supplied, the sum of the weights). If you want the heights of the bars to represent values in the data, use `geom_col()` instead. `geom_bar()` uses `stat_count()` by default: it counts the number of cases at each x position. `geom_col()` uses `stat_identity()`: it leaves the data as is.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# ## Stacking and Dodging

# By default, multiple bars at the same position are stacked on top of each other. You can change this behavior with the `position` argument. Use `position="dodge"` to place bars side-by-side. When using `position="dodge"`, bars will be grouped by the `fill`, `color`, `group`, or `dodge` aesthetic (checked in that order).

# ## Required Aesthetics

# - `x` OR `y` (not both) - the categorical variable to count

# ## Optional Aesthetics (see [`aes`](@ref))

# - `fill` (maps to bar interior color)
# - `color` / `colour` (maps to bar outline color)
# - `dodge` (grouping variable for side-by-side bars)
# - `group` (grouping variable)

# ## Optional Arguments

# - `position`: "stack" (default) or "dodge"
# - `color` / `colour`
# - `stroke` / `strokewidth`
# - `strokecolor` / `strokecolour`
# - `direction`: `:y` (default) or `:x`
# - `dodge_gap`: gap between dodged bars
# - `gap`: gap between bar groups
# - `alpha`

using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

# For basic counting, provide only an x aesthetic. The height of each bar will represent the count of observations in each category.

ggplot(penguins, @aes(x = species)) +
    geom_bar()

# You can create a horizontal bar chart by specifying `y` instead of `x`:

ggplot(penguins, @aes(y = species)) +
    geom_bar()

# Use the `fill` aesthetic to create stacked bar charts that show the breakdown of a second categorical variable:

ggplot(penguins, @aes(x = species, fill = sex)) +
    geom_bar()

# Use `position="dodge"` to place bars side-by-side for easier comparison between groups:

ggplot(penguins, @aes(x = species, fill = sex)) +
    geom_bar(position = "dodge")

# The `dodge` aesthetic can also be used directly:

ggplot(penguins, @aes(x = species, fill = sex, dodge = sex)) +
    geom_bar()

# Customize the appearance with color and stroke options:

ggplot(penguins, @aes(x = species, fill = sex)) +
    geom_bar(strokecolor = :black, strokewidth = 1, alpha = 0.8)

# Use the `gap` argument to adjust spacing between bar groups:

ggplot(penguins, @aes(x = species)) +
    geom_bar(gap = 0.5)
