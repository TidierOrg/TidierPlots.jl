# # geom_line, geom_path, and geom_step

# These geoms connect observations with lines in different ways:
# - `geom_line()` connects observations in order of the x-axis variable (most common for time series)
# - `geom_path()` connects observations in the order they appear in the data
# - `geom_step()` creates a stairstep plot, highlighting exactly when changes occur

# The `group` aesthetic determines which observations are connected together.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Lines or Makie.Stairs)

# ## Differences Between Line Geoms

# | Geom | Order | Best For |
# |------|-------|----------|
# | `geom_line()` | x-axis order | Time series, continuous functions |
# | `geom_path()` | Data order | Trajectories, paths through space |
# | `geom_step()` | x-axis order | Discrete changes, cumulative distributions |

# ## Required Aesthetics

# - `x`
# - `y`

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`
# - `group`
# - `linetype`
# - `linewidth`
# - `alpha`

# ## Optional Arguments

# - `color` / `colour`: line color
# - `colormap` / `palette`: colormap for multiple lines
# - `linestyle` / `linetype`: line pattern (e.g., `:solid`, `:dash`, `:dot`, `:dashdot`)
# - `linewidth`: line thickness
# - `alpha`: transparency

using TidierPlots
using TidierData
using DataFrames
using RDatasets

economics = dataset("ggplot2", "economics")

# ## geom_line

# `geom_line()` is ideal for time series data. Points are connected in order of the x-axis:

ggplot(economics, @aes(x = Date, y = Unemploy)) +
    geom_line()

# Customize line appearance:

ggplot(economics, @aes(x = Date, y = Unemploy)) +
    geom_line(color = :steelblue, linewidth = 2)

# Use the `color` aesthetic to draw multiple lines for different groups:

economics_long = @pivot_longer(economics, Pop:Unemploy)

ggplot(economics_long, @aes(x = Date, y = value, color = variable)) +
    geom_line()

# You can plot multiple variables by creating multiple line layers:

ggplot(economics) +
    geom_line(aes(x = :Date, y = :Unemploy), color = :blue) +
    geom_line(aes(x = :Date, y = :Pop), color = :red)

# Different line styles:

xs = range(0, 2pi, length = 50)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) +
    geom_line(linestyle = :dash, linewidth = 2)

# ## geom_path

# `geom_path()` connects points in the order they appear in the data. This is useful for trajectories or paths through 2D space:

penguins = penguins_data();

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path(alpha = 0.3)

# Create a spiral using geom_path (order in data matters):

t = range(0, 4pi, length = 100)
spiral = DataFrame(x = t .* cos.(t), y = t .* sin.(t))

ggplot(spiral, @aes(x = x, y = y)) +
    geom_path(linewidth = 2)

# ## geom_step

# `geom_step()` creates stairstep plots, useful for showing discrete changes:

ggplot(df, @aes(x = x, y = y)) +
    geom_step()

# Compare geom_line and geom_step:

df_step = DataFrame(x = 1:10, y = cumsum(rand(10)))

ggplot(df_step, @aes(x = x, y = y)) +
    geom_line(color = :blue, alpha = 0.5) +
    geom_step(color = :red)

# ## Combining with Points

# Add points to show the actual data locations:

ggplot(df, @aes(x = x, y = y)) +
    geom_line(color = :steelblue, linewidth = 1) +
    geom_point(color = :steelblue, size = 10)

# Using group aesthetic to connect subsets:

df_groups = DataFrame(
    x = repeat(1:5, 3),
    y = rand(15),
    group = repeat(["A", "B", "C"], inner = 5)
)

ggplot(df_groups, @aes(x = x, y = y, color = group)) +
    geom_line(linewidth = 2) +
    geom_point(size = 10)
