# # geom_col

# `geom_col()` creates bar charts where the heights of the bars represent values in the data. Unlike `geom_bar()`, which counts the number of cases, `geom_col()` displays the actual data values. This makes it useful for showing pre-summarized data such as means, totals, or other statistics.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# ## Stacking and Dodging

# By default, multiple bars at the same position are stacked on top of each other. You can change this behavior with the `position` argument. Use `position="dodge"` to place bars side-by-side. When using `position="dodge"`, bars will be grouped by the `fill`, `color`, `group`, or `dodge` aesthetic (checked in that order).

# ## When to Use geom_col vs geom_bar

# - Use `geom_bar()` when you want to count the number of observations in each category (the data is unsummarized)
# - Use `geom_col()` when you have pre-computed values you want to display (the data is already summarized)

# ## Required Aesthetics

# - `x` - the categorical variable
# - `y` - the numeric value to display as bar height

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
using TidierData
using DataFrames

penguins = penguins_data();

# First, we create a summarized dataset with mean bill length by species and sex:

df = @chain penguins begin
    @group_by(species, sex)
    @summarize(mean_bill_length_mm = mean(bill_length_mm))
    @ungroup()
end

# Basic bar chart showing pre-computed values:

ggplot(df, @aes(x = species, y = mean_bill_length_mm)) +
    geom_col()

# Use the `fill` aesthetic to color bars by a grouping variable. Bars are stacked by default:

ggplot(df, @aes(x = species, y = mean_bill_length_mm, fill = sex)) +
    geom_col()

# Use `position="dodge"` with the `group` aesthetic to place bars side-by-side:

ggplot(df, @aes(x = species, y = mean_bill_length_mm, group = sex)) +
    geom_col(position = "dodge")

# You can also use the `dodge` aesthetic directly:

ggplot(df, @aes(x = species, y = mean_bill_length_mm, dodge = sex)) +
    geom_col()

# Combine `fill` with position dodge for colored side-by-side bars:

ggplot(df, @aes(x = species, y = mean_bill_length_mm, fill = sex, dodge = sex)) +
    geom_col()

# Customize appearance with stroke and transparency:

ggplot(df, @aes(x = species, y = mean_bill_length_mm, fill = sex)) +
    geom_col(strokecolor = :black, strokewidth = 1, alpha = 0.8, position = "dodge")

# Create horizontal bars by using `direction = :x`:

df_single = @chain penguins begin
    @group_by(species)
    @summarize(mean_bill_length_mm = mean(bill_length_mm))
end

ggplot(df_single, @aes(x = species, y = mean_bill_length_mm)) +
    geom_col(direction = :x)
