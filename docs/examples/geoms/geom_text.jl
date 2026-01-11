# # geom_text and geom_label

# `geom_text()` adds text labels to a plot. Text labels are useful for annotating data points, adding titles to specific regions, or displaying values directly on the plot. `geom_label()` is similar but is intended to display text with a background rectangle (note: background rectangle is not yet implemented in TidierPlots).

# ## Arguments

# - `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
# - `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
# - `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
# - `inherit_aes`: should the geom inherit aes from the ggplot?
# - `...`: options that are not mapped to a column (passed to Makie.Text)

# ## Text Alignment

# Use the `align` argument to control text positioning relative to the (x, y) coordinates. Specify a tuple of horizontal and vertical alignment:
# - Horizontal: `:left`, `:center`, `:right`
# - Vertical: `:top`, `:center`, `:bottom`

# For example, `align = (:left, :bottom)` positions text so that (x, y) is at the bottom-left corner of the text.

# ## Required Aesthetics

# - `x`
# - `y`
# - `text` (can be provided as aesthetic or argument)

# ## Optional Aesthetics (see [`aes`](@ref))

# - `color` / `colour`

# ## Optional Arguments

# - `color` / `colour`: text color
# - `colormap` / `palette`: colormap for colored text
# - `align`: tuple of (horizontal, vertical) alignment (e.g., `(:left, :bottom)`)
# - `font`: font family (e.g., `:bold`, `:italic`)
# - `fontsize`: size of text
# - `rotation`: angle of rotation in radians
# - `justification`: text justification
# - `strokewidth`: outline width
# - `strokecolor`: outline color
# - `glowwidth` / `glow`: glow effect width
# - `glowcolor` / `glowcolour`: glow effect color
# - `word_wrap_width`: maximum width before wrapping
# - `alpha`

using TidierPlots
using TidierData
using DataFrames
using Parquet2

penguins = DataFrame(Parquet2.readfile(joinpath("penguins.parq")))

# ## Basic Text Labels

# Create a simple plot with text at specified positions:

df = DataFrame(
    x = [1, 1, 2, 2],
    y = [1, 2, 1, 2],
    t = ["A", "B", "C", "D"]
)

ggplot(df, @aes(x = x, y = y, text = t)) +
    geom_text()

# Add color based on the text value:

ggplot(df, @aes(x = x, y = y, text = t, color = t)) +
    geom_text()

# ## Combining with Points

# Text labels work well with points to label data:

ggplot(df, @aes(x = x, y = y, color = t)) +
    geom_point(size = 20) +
    geom_text(@aes(text = t), fontsize = 24, align = (:left, :bottom)) +
    lims(x = (0, 3), y = (0, 3))

# ## Font Styling

# Customize font size, style, and color:

ggplot(df, @aes(x = x, y = y, text = t)) +
    geom_text(fontsize = 30, font = :bold, color = :steelblue)

# ## Text Alignment

# Control where the text appears relative to the point:

ggplot(df, @aes(x = x, y = y)) +
    geom_point(size = 15) +
    geom_text(@aes(text = t), fontsize = 20, align = (:center, :bottom)) +
    lims(x = (0.5, 2.5), y = (0.5, 2.5))

# Different alignment options:

ggplot(df, @aes(x = x, y = y)) +
    geom_point(size = 15) +
    geom_text(@aes(text = t), fontsize = 20, align = (:left, :center)) +
    lims(x = (0.5, 2.5), y = (0.5, 2.5))

# ## Labeling Real Data

# Label species on a scatterplot (using summarized data):

import Statistics: mean

species_centroids = @chain penguins begin
    @group_by(species)
    @summarize(
        bill_length_mm = mean(bill_length_mm),
        bill_depth_mm = mean(bill_depth_mm)
    )
end

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(color = species), alpha = 0.5) +
    geom_text(data = species_centroids, @aes(text = species),
        fontsize = 20, font = :bold)

# ## Text with Outline

# Use strokewidth and strokecolor for better visibility:

ggplot(df, @aes(x = x, y = y, text = t)) +
    geom_text(fontsize = 40, strokewidth = 2, strokecolor = :black, color = :white)

# ## Rotated Text

# Use the rotation argument (in radians):

ggplot(df, @aes(x = x, y = y, text = t)) +
    geom_text(fontsize = 30, rotation = pi/4)

# ## geom_label

# `geom_label()` works the same as `geom_text()`. Note that the background rectangle feature is not yet implemented:

ggplot(df, @aes(x = x, y = y, text = t, color = t)) +
    geom_label(fontsize = 24)

# Combining label with points:

ggplot(df, @aes(x = x, y = y, color = t)) +
    geom_label(@aes(text = t), fontsize = 24, align = (:left, :bottom), font = :bold) +
    geom_point() +
    lims(x = (0, 3), y = (0, 3))

# ## Practical Example: Annotating Bar Charts

summary_df = @chain penguins begin
    @group_by(species)
    @summarize(count = n())
end

ggplot(summary_df, @aes(x = species, y = count)) +
    geom_col() +
    geom_text(@aes(text = count), fontsize = 20, align = (:center, :bottom))
