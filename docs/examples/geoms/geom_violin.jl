# # geom_violin

# A violin plot is a compact display of a continuous distribution. It is a mirrored density plot displayed in the same way as a boxplot. Violin plots are useful for comparing distributions across groups, as they show more detail about the shape of the distribution than boxplots while still being compact.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Violin)

# ## Violin vs Boxplot

# Both violin plots and boxplots display distributions, but they show different information:
# - **Violin plots** show the full shape of the distribution (including multimodality)
# - **Boxplots** show summary statistics (median, quartiles, outliers)
# - Use violin plots when the shape of the distribution matters
# - Use boxplots when you want to compare specific statistics

# ## Required Aesthetics

# - `x` (categorical or integer)
# - `y` (numeric)

# ## Optional Aesthetics (see [`aes`](@ref))

# - `fill` (maps to violin interior color)
# - `color` / `colour` (maps to violin outline color)
# - `dodge` (grouping variable for side-by-side violins)

# ## Optional Arguments

# - `orientation`: `:vertical` (default) or `:horizontal`
# - `width`: width of the violins (default: 1)
# - `gap`: gap between violins (default: 0.2)
# - `show_notch`: whether to show notches (default: false)
# - `notchwidth`: width of the notches (default: 0.5)
# - `show_median`: whether to show the median line (default: true)
# - `dodge_gap`: gap between dodged violins (default: 0.03)
# - `strokecolor` / `strokecolour`
# - `strokewidth`
# - `alpha`

using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

# ## Basic Violin Plot

# Create a basic violin plot showing the distribution of bill length for each species:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin()

# ## Horizontal Violins

# Create horizontal violin plots using the `orientation` argument:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(orientation = :horizontal)

# ## Grouped Violins

# Use the `fill` aesthetic to compare distributions across an additional categorical variable:

ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = sex)) +
    geom_violin()

# Use `dodge` to place violins side-by-side:

ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = sex, dodge = sex)) +
    geom_violin()

# ## Customizing Appearance

# Add stroke color and adjust transparency:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(color = :steelblue, strokecolor = :black, strokewidth = 2)

# Different fill colors:

ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = species)) +
    geom_violin(strokecolor = :black, strokewidth = 1)

# ## Combining with Other Geoms

# Combine violin with boxplot for more information:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin() +
    geom_boxplot(width = 0.2, alpha = 0.8)

# Add individual data points:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(alpha = 0.5) +
    geom_point(alpha = 0.3)

# Use jittered points for better visibility:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(strokecolor = :black) +
    geom_jitter(alpha = 0.3, width = 0.1)

# ## Comparing Multiple Variables

# Compare distributions across different measurements:

ggplot(penguins, @aes(x = species, y = flipper_length_mm)) +
    geom_violin() +
    labs(title = "Flipper Length by Species")

#-

ggplot(penguins, @aes(x = species, y = body_mass_g)) +
    geom_violin() +
    labs(title = "Body Mass by Species")

# ## Using with Facets

# Use faceting to compare distributions across multiple categorical variables:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin() +
    facet_wrap(:sex)

# ## Violin vs Density Comparison

# Violin plots are essentially mirrored density plots. Compare:

ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
    geom_density()

# The violin plot shows the same information but in a compact, comparative format:

ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = species)) +
    geom_violin()
