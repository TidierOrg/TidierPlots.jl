using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

# ## `ggplot()`
# `ggplot()` is the starting point of any plot. It sets up the initial plot with default settings that can be later customized with geoms, scales, theme settings and other specifications. `ggplot` usually used with a data source as an argument, and optionally, a set of aesthetics specified by @aes(). The data source is typically a DataFrame.

# If a set of aesthetics is specified in the initial ggplot call, these aesthetics apply to all layers added to the plot, unless they are overridden in subsequent layers.

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
    geom_point()

# ## `@aes()`
# `aes()` is used to map variables in your data to visual properties (aesthetics) of the plot. These aesthetics can include things like position (x and y coordinates), color, shape, size, etc. Each aesthetic is a way of visualizing a variable or a statistical transformation of a variable.

# Aesthetics are specified in the form aes(aesthetic = variable), where aesthetic is the name of the aesthetic, and variable is the column name in your data that you want to map to the aesthetic. The variable names do not need to be preceded by a colon.

# Of note, TidierPlots.jl accepts multiple forms for aes specification, none of which is *exactly* the same as ggplot2.

#   - Option 1: `@aes` macro, aes as in ggplot, e.g. `@aes(x = x, y = y)`
#   - Option 2: `@es` macro, aes as in ggplot, e.g. `@es(x = x, y = y)`
#   - Option 3: `aes` function, julia-style columns, e.g. `aes(x = :x, y = :y)`
#   - Option 4: `aes` function, strings for columns, e.g. `aes(x = "x", y = "y")`

# The examples below will generally use *option 1*

# In the above example, we can see that the x, y, and color aesthetics are being mapped to each subsequent layer of the plot.

# In general, `aes()` can be used within the `ggplot`  to set global aesthetics that apply to all layers, or within individual geoms to set aesthetics that apply only to that layer.

# Moving from general rules, to specific plots, let us first explore `geom_point()`

# `geom_point()`
# `geom_point` is used to create a scatter plot. It is typically used with aesthetics mapping variables to x and y positions, and optionally to other aesthetics like color, shape, and size. `geom_point` can be used to visualize the relationship between two continuous variables, or a continuous and a discrete variable. The following visuals features can be changed within `geom_point()`, shape, size, stroke, strokecolour, and alpha .

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
    geom_point( size = 20,
                stroke = 1,
                strokecolor = "black",
                alpha = 0.2) +
    labs(x = "Bill Length (mm)", y = "Bill Width (mm)") +
    lims(x = c(40, 60), y = c(15, 20)) +
    theme_minimal()

# In the example above, a scatter plot is created with the variable bill_length_mm mapped to the x position, and bill_depth_mm mapped to the y position with color mapped to species. Supported optional arguements include:
# - size - this is the size of the marker
# - alpha (or transparency), is set to a value between 0 and 1.
# - strokecolor is the stroke color around the marker. https://juliagraphics.github.io/Colors.jl/stable/namedcolors/ colors can be chosen from any name on this list
# - stroke this is the thickeness of the stroke around the marker

# ## `lims`
# `lims` allows the user to set the ranges for the x and y axises as shown in the example above.

# ## `geom_bar`, `geom_col`, and `geom_histogram`
# `geom_bar` is used to create bar plots for categorical data.  `geom_col`  is a special case of `geom_bar` where the height of the bars is already computed and does not need to be counted. `geom_histogram`  is used to create a histogram, which is essentially a bar plot for continuous data, where the data is divided into bins and the number of data points in each bin is counted.

ggplot(data=penguins, @aes(x=species)) +
  geom_bar(aes(color = "island"), position = "dodge")

# geom_bar optional arguments include
         # - color, alpha as above
         # - position, when set to "dodge," bar charts will not stack


ggplot(data=penguins, @aes(x = island, y=species)) +
    geom_col()
#-
ggplot() +
  geom_histogram(data=penguins, @aes(x = bill_length_mm))

# In the first example, a bar plot is created with the variable CategoricalVar mapped to the x position, and the count of each category is represented by the height of the bars.

# In the second example, a column plot is created with the variable CategoricalVar mapped to the x position, and ComputedHeight mapped to the y position.

# A histogram is created with the continuous variable, bill_length_mm, mapped to the x position, and the data is divided into bins, with the count in each bin represented by the height of the bars.

# ## `geom_path` and `geom_line`
# The `geom_path` and `geom_line`  are used to create line plots. `geom_path` connects the data points in the order they appear in the data, while `geom_line` connects the data points in order of the x-values.

x_values = 1:10;
y_values = x_values .^ 2;
df_line = DataFrame(X = x_values, Y = y_values);
ggplot(df_line) +
    geom_line(@aes(x = X, y = Y)) +
    labs(title = "Line Plot Example", x = "X axis", y = "Y axis")+
    theme_dark()

# ## `geom_step`
#  `geom_step` creates a step plot, which is similar to a line plot but with a step pattern rather than a direct line from point to point.

ggplot(df_line, @aes(x = X, y = Y)) +
    geom_step() +
    labs(title = "Step Plot Example", x = "X axis", y = "Y axis")+
    theme_minimal()


# ## `geom_boxplot`
# `geom_boxplot` creates a boxplot.

ggplot()+
  geom_boxplot(data=penguins, @aes(x = island, y = bill_length_mm))

# In this example, a boxplot is created where different island of penguins are mapped to the x position, and the bill length is mapped to the y position. Finally, the each species will be mapped to a different color

# geom_boxplot supported optinal arguements currently include:
       # - color - if used within the aes() with a categorical variable it will make each category a different color as shown above. When used outside of the aes() and selected with a color, it will make each boxplot that color.
       # - alpha - transaparency as above, used outside of the aes()

# ## `geom_violin`
# `geom_violin`  creates a violin plot, which is a combination of a boxplot and a kernel density plot.

ggplot(penguins, @aes(x = species, y = bill_depth_mm)) +
    geom_violin()

# In this example, a violin plot is created where different species of penguins are mapped to the x position, and the bill depth is mapped to the y position. geom_violin does not currently support mapping a categorical variable to colors.

# ## `geom_tile`
# The `geom_tile` creates a tile plot, also known as a heatmap.

x_values = repeat(1:5, inner = 5);
y_values = repeat(1:5, outer = 5);
values = x_values .* y_values;
df_tile = DataFrame(X = x_values, Y = y_values, Value = values);

ggplot(df_tile, @aes(x = X, y = Y, z = Value)) +
    geom_tile() +
    labs(title = "Tile Plot Example", x = "X axis", y = "Y axis")

# ## `geom_text` and `geom_label`
# `geom_text` and `geom_label`  are used to add text and labels to a plot.

# ## Combining plots
# Similar to the `patchwork` library in R, plots can be combined horizontally using the `+` and `|` operators and vertically with the `/` operator.

plot = ggplot(df_tile, @aes(x = X, y = Y, z = Value)) +
           geom_tile();

plot | plot

plot / plot

# These extend beyond two plots, but must be used in functional form for `|` and `/`.

plot + plot + plot

/(plot, plot, plot)

# Grids of plots can also be combined using parethesis to delimit grid boundaries.

((plot + plot + plot) | plot) / (plot / plot)

# ## `scale_x_continuous`,  `scale_y_continuous`
# `scale_x_continuous` and `scale_y_continuous` can apply labels and scales, reverse, or adjust the ticks for the axis.

ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm)) +
    geom_point() +
    scale_x_continuous(
        name="Mass (g)",
        trans=log10
    ) +
    scale_y_continuous(
        name="Length",
        reversed = true,
        labels=label_number(;suffix="mm")
    )

# The `trans` argument takes as input a function which takes in and outputs numerical values. and `labels` argument can be a string specification from `Format.jl` or a function which formats a list of strings.
# Available label generators are:
# - `label_bytes`
# - `label_currency`
# - `label_date`
# - `label_log`
# - `label_number`
# - `label_ordinal`
# - `label_percent`
# - `label_pvalue`
# - `label_scientific`
# - `label_wrap`
# Each of these will accept keywords arguments to generate a label function compatible with the `labels` argument.

# ## `scale_x_log10`,  `scale_y_log10`
# `scale_x_log10` and `scale_y_log10` apply a base 10 logarithmic transformation to the x and y axes, respectively.

ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm)) +
    geom_point() +
    scale_x_log10()

# In this example, a scatter plot is created where the body mass of penguins is mapped to the x position and the bill length to the y position. A base 10 logarithmic transformation is then applied to the x-axis.

# ## `scale_x_log2`, `scale_y_log2`, `scale_x_log`, `scale_y_log`
# These work similarly to the previous ones, but apply a base 2 or base e logarithmic transformation to the x and y axes, respectively.

# ## `scale_x_logit`, `scale_y_logit`
# `scale_x_logit` and `scale_y_logit apply a logit transformation to the x and y axes, respectively. This transformation is often used when visualizing proportions or probabilities.

# ## `scale_x_pseudolog10`, `scale_y_pseudolog10`, `scale_x_Symlog10`, `scale_y_Symlog10`
# These apply different types of logarithmic transformations to the x and y axes. The "pseudo" and "Symlog" transformations are designed to handle zeros and negative values more effectively.

# ## `scale_x_reverse`, `scale_y_reverse`
# `scale_x_reverse` and `scale_y_reverse`  reverse the direction of the x and y axes, respectively.

ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm, color = species)) +
   geom_point() +
   scale_y_reverse() +
   theme_minimal()

# In this example, a scatter plot is created where the body mass of penguins is mapped to the x position and the bill length to the y position. The direction of the y-axis is then reversed.

# ## `scale_x_sqrt`, `scale_y_sqrt`
#  `scale_x_sqrt` and `scale_y_sqrt`  apply a square root transformation to the x and y axes, respectively.

ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm, color = species)) +
   geom_point() +
   scale_x_sqrt() +
   theme_minimal()

# In this example, a scatter plot is created where the body mass of penguins is mapped to the x position and the bill length to the y position. A square root transformation is then applied to the x-axis

# ## `geom_errorbar`
# `geom_errorbar` creates vertical and error bars .

categories = ["A", "B", "C", "D"];
n = length(categories);

mean_values = rand(n);  # Random mean values for demonstration
errors = rand(n) / 2;   # Random error values for demonstration

LowerBound = mean_values .- errors;
UpperBound = mean_values .+ errors;

df_errorbar = DataFrame(
    Category = categories,
    MeanValue = mean_values,
    LowerBound = LowerBound,
    UpperBound = UpperBound);

ggplot(df_errorbar, @aes(x = Category, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) +
    geom_point() + # to show the mean value
    geom_errorbar(width = 0.2) + # width of the horizontal line at the top and bottom of the error bar
    labs(title = "Error Bar Plot Example", x = "Category", y = "Mean Value")

# ## `ggsave`
#  `ggsave` saves a GGPlot to the specified location.

plot = ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm, color = species)) +
           geom_point()

ggsave(plot, "penguin_points.png")

# In this example, `plot` is saved to `penguin_points.png`. Acceptable filetypes are all those supported by CairoMakie: `svg`, `pdf`, and `png`.
