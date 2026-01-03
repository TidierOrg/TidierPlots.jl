# # geom_histogram

# Visualises the distribution of a single continuous variable by dividing the x-axis into bins and counting the number of observations in each bin. Histograms are useful for showing the shape of the distribution, including the center, spread, and skewness. For smooth density estimates, see `geom_density()`.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Hist)

# ## Choosing Bins

# The appearance of a histogram depends heavily on the number and width of bins. You should always explore multiple bin widths to find the best representation of your data. Key binning options:
# - `bins`: number of bins (default: 30) or a vector of bin edges
# - `binwidth`: width of each bin (alternative to bins)
# - `center`: ensures a bin is centered on this value (useful for discrete data)
# - `boundary`: ensures a bin edge falls at this value

# ## Normalization

# By default, the y-axis shows counts. Use the `normalization` argument to change this:
# - `:none` (default): bar heights represent counts
# - `:probability`: bar heights represent the probability of each bin
# - `:pdf`: probability density (area under histogram sums to 1)

# ## Required Aesthetics

# - `x`

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour` (used for grouping)

# ## Optional Arguments

# - `bins`: number of bins (default: 30) or a vector of bin edges
# - `binwidth`: width of each bin (alternative to bins)
# - `center`: value that should be at the center of a bin
# - `boundary`: value that should be at a bin edge
# - `normalization`: `:none`, `:probability`, or `:pdf`
# - `color` / `colour`: fill color
# - `stroke` / `strokewidth`: outline width
# - `strokecolor` / `strokecolour`: outline color
# - `alpha`

using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

# Create a basic histogram of bill length:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram()

# Change the number of bins to show more or less detail:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(bins = 20)

#-

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(bins = 50)

# Use `binwidth` to set a specific bin width:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(binwidth = 2)

# Show probability instead of counts:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization = :probability, bins = 20)

# For discrete/integer data, use `center` to align bars with tick marks. This centers a bin on the specified value:

df_discrete = DataFrame(counts = rand(1:10, 100))

ggplot(df_discrete, @aes(x = counts)) +
    geom_histogram(binwidth = 1, center = 0)

# Use `boundary` instead if you want bin edges at specific values:

ggplot(df_discrete, @aes(x = counts)) +
    geom_histogram(binwidth = 1, boundary = 0.5)

# Customize appearance with colors and stroke:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(bins = 25, color = :steelblue, strokecolor = :black, strokewidth = 1)

# Use the `color` aesthetic to create stacked or grouped histograms by a categorical variable:

ggplot(penguins, @aes(x = bill_length_mm, color = species)) +
    geom_histogram(bins = 20, alpha = 0.7)

# Combine histogram with density for comparison (use normalization = :pdf to make them comparable):

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization = :pdf, bins = 20, alpha = 0.5) +
    geom_density(strokecolor = :red, stroke = 2)

# Use faceting to compare distributions across groups:

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(bins = 15) +
    facet_wrap(:species)
