# # geom_tile

# `geom_tile()` creates heatmaps by plotting a collection of rectangles. Each tile is positioned at (x, y) and colored according to the z value. This is useful for visualizing matrices, correlation tables, 2D data, and any data where you want to represent a third variable as color across a grid.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Heatmap)

# ## Data Requirements

# The data must be in "long" format with columns for x, y, and z (the value to be displayed as color):
# - `x` and `y` define the position of each tile
# - `z` defines the color/value of each tile
# - All three columns must be the same length
# - There should be no duplicate (x, y) pairs

# Think of the data as triples of the form (x, y, f(x, y)) where z = f(x, y).

# ## Required Aesthetics

# - `x`
# - `y`
# - `z`

# ## Optional Aesthetics (see [`aes`](@ref))

# None (color is determined by z values)

# ## Optional Arguments

# - `interpolate`: whether to interpolate between tiles (default: false)
# - `colormap` / `palette`: colormap for the z values
# - `alpha`: transparency

using TidierPlots
using TidierData
using DataFrames

# ## Basic Heatmap

# Create a simple grid of values:

df_simple = DataFrame(
    x = repeat(1:5, inner = 5),
    y = repeat(1:5, outer = 5),
    z = rand(25)
)

ggplot(df_simple, @aes(x = x, y = y, z = z)) +
    geom_tile()

# ## Mathematical Function Visualization

# Visualize a mathematical function using geom_tile. Here's the classic Mandelbrot set:

function mandelbrot(x, y)
    z = c = x + y*im
    for i in 1:30.0
        abs(z) > 2 && return i
        z = z^2 + c
    end
    return 0
end

xs = -2:0.01:1
ys = -1.1:0.01:1.1
xys = Iterators.product(xs, ys) |> collect |> vec
zs = map(xy -> mandelbrot(xy[1], xy[2]), xys)

df_mandelbrot = DataFrame(
    x = first.(xys),
    y = last.(xys),
    z = zs
)

ggplot(df_mandelbrot, @aes(x = x, y = y, z = z)) +
    geom_tile()

# ## Correlation Matrix

# Heatmaps are commonly used to visualize correlation matrices:


using Statistics

penguins = penguins_data()

# Select numeric columns and compute correlation
numeric_cols = [:bill_length_mm, :bill_depth_mm, :flipper_length_mm, :body_mass_g]
cor_matrix = cor(Matrix(penguins[:, numeric_cols]))

# Convert to long format for plotting
n = length(numeric_cols)
cor_df = DataFrame(
    x = repeat(1:n, inner = n),
    y = repeat(1:n, outer = n),
    z = vec(cor_matrix)
)

ggplot(cor_df, @aes(x = x, y = y, z = z)) +
    geom_tile()

# ## Custom Colormap

# Use different colormaps to change the appearance:

df_gradient = DataFrame(
    x = repeat(1:10, inner = 10),
    y = repeat(1:10, outer = 10),
    z = [(i + j) / 20 for i in 1:10 for j in 1:10]
)

ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
    geom_tile(colormap = :viridis)

#-

ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
    geom_tile(colormap = :thermal)

#-

ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
    geom_tile(colormap = :RdBu)

# ## Sine Wave Pattern

# Create a 2D sine wave pattern:

xs = range(0, 4pi, length = 50)
ys = range(0, 4pi, length = 50)
xys = Iterators.product(xs, ys) |> collect |> vec

df_sine = DataFrame(
    x = first.(xys),
    y = last.(xys),
    z = [sin(x) * cos(y) for (x, y) in xys]
)

ggplot(df_sine, @aes(x = x, y = y, z = z)) +
    geom_tile(colormap = :coolwarm)

# ## Checkerboard Pattern

# Create a checkerboard pattern:

checkerboard = DataFrame(
    x = repeat(1:8, inner = 8),
    y = repeat(1:8, outer = 8),
    z = [mod(i + j, 2) for i in 1:8 for j in 1:8]
)

ggplot(checkerboard, @aes(x = x, y = y, z = z)) +
    geom_tile(colormap = :grays)

# ## Transparency

# Use alpha to make tiles semi-transparent:

ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
    geom_tile(alpha = 0.7, colormap = :plasma)
