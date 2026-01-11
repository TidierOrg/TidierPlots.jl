# # geom_boxplot

# The boxplot compactly displays the distribution of a continuous variable. It visualises five summary statistics (the median, two hinges and two whiskers), and all "outlying" points individually. The box represents the interquartile range (IQR), with the median shown as a line inside the box. The whiskers extend to the most extreme data points that are within 1.5 times the IQR from the box. Points beyond the whiskers are considered outliers and are plotted individually.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.BoxPlot)

# ## Orientation

# This geom can be oriented either vertically or horizontally. The orientation is automatically determined based on the data types of the aesthetics. If `x` is categorical and `y` is continuous, the boxplot will be vertical. If `y` is categorical and `x` is continuous, the boxplot will be horizontal.

# ## Summary Statistics

# The boxplot displays:
# - **Median**: the middle value, shown as a line in the box
# - **Hinges**: the 25th and 75th percentiles, forming the top and bottom of the box
# - **Whiskers**: extend to the most extreme points within 1.5 * IQR from the hinges
# - **Outliers**: points beyond the whiskers, plotted individually

# ## Required Aesthetics

# - `x` (categorical or integer)
# - `y` (numeric)

# ## Optional Aesthetics (see [`aes`](@ref))

# - `fill` (maps to box interior color)
# - `color` / `colour` (maps to box outline color)
# - `dodge` (grouping variable for side-by-side boxes)

# ## Optional Arguments

# - `orientation`: `:vertical` (default) or `:horizontal`
# - `width`: width of the boxes (default: 1)
# - `gap`: gap between boxes (default: 0.2)
# - `show_notch`: whether to show notches for median comparison (default: false)
# - `notchwidth`: width of the notches (default: 0.5)
# - `show_median`: whether to show the median line (default: true)
# - `dodge_gap`: gap between dodged boxes (default: 0.03)
# - `strokecolor` / `strokecolour`
# - `strokewidth`
# - `alpha`

using TidierPlots
using DataFrames
using Parquet2

penguins = DataFrame(Parquet2.readfile(joinpath("penguins.parq")))

# Create a basic boxplot showing the distribution of bill length for each species:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot()

# For horizontal boxplots, swap the x and y aesthetics. The orientation is automatically detected:

ggplot(penguins, @aes(y = species, x = bill_length_mm)) +
    geom_boxplot()

# Use the `fill` aesthetic to compare distributions across an additional categorical variable. Boxes are automatically dodged when fill is specified:

ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = sex)) +
    geom_boxplot()

# You can also use `dodge` explicitly to group boxes:

ggplot(penguins, @aes(x = species, y = bill_length_mm, dodge = sex)) +
    geom_boxplot()

# Add notches to compare medians. Non-overlapping notches suggest the medians are significantly different:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot(show_notch = true, notchwidth = 0.5)

# Customize the appearance with stroke and fill options:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot(color = :steelblue, strokecolor = :black, strokewidth = 2, alpha = 0.7)

# Combine boxplots with other geoms like points for more detailed visualizations:

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot(alpha = 0.5) +
    geom_point(@aes(color = sex), alpha = 0.5)
