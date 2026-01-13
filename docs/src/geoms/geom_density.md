# geom_density

Computes and draws kernel density estimates, which is a smoothed version of the histogram. This is a useful alternative to the histogram for continuous data that comes from an underlying smooth distribution. The density estimate provides a smooth curve that shows the shape of the distribution without the binning artifacts that can appear in histograms.

## Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to. This is typically used to facilitate creating your ggplot as part of a @chain.
- `data` (DataFrame): Data to use for this geom. If not provided, the geom will inherit the data from ggplot.
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `inherit_aes`: should the geom inherit aes from the ggplot?
- `...`: options that are not mapped to a column (passed to Makie.Density)

## Density vs Histogram

Density plots and histograms both display the distribution of a continuous variable, but they have different characteristics:
- **Density plots** show a smooth curve that is easier to interpret and compare across groups
- **Histograms** show discrete bins that can reveal fine structure in the data
- Density plots work best when the underlying distribution is smooth
- Histograms work better for discrete or multimodal data

## Required Aesthetics

- `x`

## Optional Aesthetics (see [`aes`](@ref))

- `fill` (maps to fill color under the curve)
- `color` / `colour` (maps to outline color)
- `strokecolor` / `strokecolour`

## Optional Arguments

- `color` / `colour`: fill color of the density area
- `colormap` / `palette`: colormap for multiple densities
- `strokecolor` / `strokecolour`: outline color
- `strokewidth` / `stroke`: outline width
- `linestyle` / `linetype`: outline style
- `direction`: `:x` (default) for vertical density, `:y` for horizontal
- `npoints`: number of points used to draw the density curve (default: 200)
- `alpha`

```@example geom_density
using TidierPlots
using DataFrames

penguins = penguins_data();
nothing # hide
```

Create a basic density plot showing the distribution of bill length:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_density()
```

Customize the appearance with fill color and stroke:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_density(color = :steelblue, strokecolor = :black, stroke = 2)
```

Use the `fill` aesthetic to compare distributions across groups. Each group gets its own density curve:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
    geom_density(alpha = 0.5)
```

Add stroke color to distinguish overlapping densities more clearly:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
    geom_density(alpha = 0.4, strokecolor = :black, stroke = 1)
```

Use `strokecolor` aesthetic to color just the outline:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm, strokecolor = species)) +
    geom_density(stroke = 2)
```

Combine density with other geoms for richer visualizations:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization = :pdf, alpha = 0.3) +
    geom_density(strokecolor = :red, stroke = 2)
```

Compare distributions across two categorical variables:

```@example geom_density
ggplot(penguins, @aes(x = bill_length_mm, fill = sex)) +
    geom_density(alpha = 0.5) +
    facet_wrap(:species)
```
