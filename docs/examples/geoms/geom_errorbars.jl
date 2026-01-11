# # geom_errorbar and geom_errorbarh

# Error bars display uncertainty in data values by showing a range around each point. `geom_errorbar()` creates vertical error bars, while `geom_errorbarh()` creates horizontal error bars. These are commonly used to show confidence intervals, standard errors, or other measures of variability around summary statistics.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# ## Vertical vs Horizontal

# Use `geom_errorbar()` when your error bars should be vertical (most common case, e.g., when x is categorical and y is numeric). Use `geom_errorbarh()` when your error bars should be horizontal (e.g., when y is categorical and x is numeric).

# ## Required Aesthetics (geom_errorbar)

# - `x` - the x position of the error bar
# - `ymin` - the lower end of the error bar
# - `ymax` - the upper end of the error bar

# ## Required Aesthetics (geom_errorbarh)

# - `y` - the y position of the error bar
# - `xmin` - the left end of the error bar
# - `xmax` - the right end of the error bar

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`

# ## Optional Arguments

# - `color` / `colour`: color of the error bars
# - `linewidth`: width of the error bar lines
# - `whiskerwidth` / `width`: width of the whisker caps (in pixels)
# - `alpha`

using TidierPlots
using TidierData
using DataFrames
using Statistics

penguins = penguins_data()

# First, create a summary dataset with means and standard deviations:

df = @chain penguins begin
    @group_by(species)
    @summarize(
        mean_bill = mean(bill_length_mm),
        sd_bill = std(bill_length_mm),
        n = n()
    )
    @mutate(
        se_bill = sd_bill / sqrt(n)
    )
    @mutate(
        lower = mean_bill - 1.96 * se_bill,
        upper = mean_bill + 1.96 * se_bill
    )
end

# Basic error bars showing 95% confidence intervals:

ggplot(df, @aes(x = species, ymin = lower, ymax = upper)) +
    geom_errorbar(linewidth = 2)

# Add whisker caps to make the endpoints more visible:

ggplot(df, @aes(x = species, ymin = lower, ymax = upper)) +
    geom_errorbar(linewidth = 2, whiskerwidth = 20)

# Combine error bars with points to show both the central value and uncertainty:

ggplot(df, @aes(x = species, y = mean_bill, ymin = lower, ymax = upper)) +
    geom_errorbar(linewidth = 1, whiskerwidth = 15) +
    geom_point(size = 15)

# Combine with bar charts:

ggplot(df, @aes(x = species, y = mean_bill, ymin = lower, ymax = upper)) +
    geom_col(alpha = 0.5) +
    geom_errorbar(linewidth = 2, whiskerwidth = 20)

# Create horizontal error bars using geom_errorbarh:

df_h = @chain penguins begin
    @group_by(species)
    @summarize(
        mean_bill = mean(bill_length_mm),
        sd_bill = std(bill_length_mm),
        n = n()
    )
    @mutate(
        se_bill = sd_bill / sqrt(n)
    )
    @mutate(
        lower = mean_bill - 1.96 * se_bill,
        upper = mean_bill + 1.96 * se_bill
    )
end

ggplot(df_h, @aes(y = species, xmin = lower, xmax = upper)) +
    geom_errorbarh(linewidth = 2)

# Example with custom error bar data:

df_custom = DataFrame(
    trt   = [1, 1, 2, 2],
    resp  = [1, 5, 3, 4],
    group = ["A", "B", "A", "B"],
    lower = [0.8, 4.6, 2.4, 3.6],
    upper = [1.1, 5.3, 3.3, 4.2]
)

ggplot(df_custom, @aes(x = trt, y = resp, ymin = lower, ymax = upper, color = group)) +
    geom_errorbar(whiskerwidth = 20, linewidth = 2) +
    geom_point(size = 15)
