# # geom_point

# The point geom is used to create scatterplots. The scatterplot is most useful for displaying the relationship between two continuous variables. It can be used to compare one continuous and one categorical variable, or two categorical variables, but other charts are usually more appropriate. A bubblechart is a scatterplot with a third variable mapped to the size of points.

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Scatter)

# ## Overplotting

# The biggest potential problem with a scatterplot is overplotting: whenever you have more than a few points, points may be plotted on top of one another. This can severely distort the visual appearance of the plot. There is no one solution to this problem, but there are some techniques that can help. You can add additional information with geom\_smooth(), or if you have few unique x values, geom\_boxplot() may also be useful. Another technique is to make the points transparent (e.g. geom\_point(alpha = 0.05)) or very small (e.g. geom\_point(shape = '.')).

# ## Required Aesthetics

# - `x`
# - `y`

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`
# - `fill`
# - `shape`
# - `size`
# - `stroke`

# ## Optional Arguments

# - `color` / `colour`
# - `colormap` / `palette`
# - `marker` / `shape`
# - `markersize` / `size`
# - `strokewidth` / `stroke`
# - `strokecolor` / `strokecolour`
# - `glowwidth` / `glow`
# - `glowcolor` / `glowcolour`
# - `alpha`

using TidierPlots
using DataFrames
using RDatasets
using CategoricalArrays
using Makie
using Parquet2

penguins = DataFrame(Parquet2.readfile(joinpath("penguins.parq")))
diamonds = dataset("ggplot2", "diamonds");
mtcars = dataset("datasets", "mtcars");

# For a basic scatterplot, you need data, an x aes, and a y aes.

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point()

# Add aesthetics, such as color:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(color = sex))

# Shape:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(shape = sex)) + scale_shape()

# Or size, to make a "bubblechart":

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(size = body_mass_g)) +
    scale_size(range = [5, 15], name = "Body Mass (g)")

# Aesthetics can also be set to a fixed value by setting them outside the aes function:

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(size=18, alpha = 0.5)

# Varying alpha can be useful for large datasets so you can see the density of points.

ggplot(diamonds, aes(x = :Carat, y = :Price)) +
    geom_point(alpha=0.1)

#-

ggplot(diamonds, aes(x = :Carat, y = :Price)) +
    geom_point(alpha=0.05)

#-

ggplot(diamonds, aes(x = :Carat, y = :Price)) +
    geom_point(alpha=0.02)

# All shapes can have both color and fill set. Refer to shapes by their name.

ggplot(mtcars, aes(x=:WT, y=:MPG, fill = :Cyl => CategoricalArray)) +
    geom_point(shape=:circle, strokecolor="black", size=30, stroke=5)

# Create simple compound shapes using multiple geom_point layers, or see the Makie documentation for more advanced shapes.

ggplot(mtcars, aes(x=:MPG, y=:WT, shape=:Cyl => CategoricalArray)) +
    geom_point(aes(colour=:Cyl => CategoricalArray), size=20) +
    geom_point(size=10) + scale_shape()

# Makie allows basically any shape you want to be used as a scatter marker. Here, we construct a Bat Symbol using a BezierPath:

batsymbol_string = "M96.84 141.998c-4.947-23.457-20.359-32.211-25.862-13.887-11.822-22.963-37.961-16.135-22.041 6.289-3.005-1.295-5.872-2.682-8.538-4.191-8.646-5.318-15.259-11.314-19.774-17.586-3.237-5.07-4.994-10.541-4.994-16.229 0-19.774 21.115-36.758 50.861-43.694.446-.078.909-.154 1.372-.231-22.657 30.039 9.386 50.985 15.258 24.645l2.528-24.367 5.086 6.52H103.205l5.07-6.52 2.543 24.367c5.842 26.278 37.746 5.502 15.414-24.429 29.777 6.951 50.891 23.936 50.891 43.709 0 15.136-12.406 28.651-31.609 37.267 14.842-21.822-10.867-28.266-22.549-5.549-5.502-18.325-21.147-9.341-26.125 13.886z"

batsymbol = BezierPath(batsymbol_string, fit=true, flipy=true)

ggplot(mtcars) + geom_point(aes(x=:MPG, y=:WT), shape=batsymbol, size=20)
