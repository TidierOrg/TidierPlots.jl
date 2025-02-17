# # Connect Observations

# `geom_path()` connects the observations in the order in which they appear in the data. `geom_line()` connects them in order of the variable on the x axis. `geom_step()` creates a stairstep plot, highlighting exactly when changes occur. The group aesthetic determines which cases are connected together.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Lines)

# ## Required Aesthetics

# - `x`
# - `y`

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`
# - `alpha`
# - `group`
# - `linetype`
# - `linewidth`

using TidierPlots
using TidierData
using DataFrames
using RDatasets

economics = dataset("ggplot2", "economics")
economics_long = @pivot_longer(economics, -Date)

# geom_line is suitable for time series

ggplot(economics, @aes(x = Date, y = Unemploy)) + geom_line()

# -

ggplot(economics) +
    [geom_line(aes(x = :Date, y = v)) for v in [:Unemploy, :PCE, :Pop]]






using Dates

xdates = Date.(["2025-02-17", "2025-02-18"])
xnums = [1, 2]
nums1 = [1, 2]
nums2 = [3, 4]

f, _, pl = lines(xdates, nums1)
lines!(f[1,1], xdates, nums2)

Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Lines,
                        xdates,
                        nums1),
                    Makie.PlotSpec(
                        :Lines,
                        xdates,
                        nums2)
                ]
            )
        )
    )



ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path()

xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_step()
