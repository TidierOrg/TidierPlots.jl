"""
    geom_histogram(aes(...), ...)
    geom_histogram(plot::GGPlot, aes(...), ...)

Represents data as a histogram.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Hist)

# Required Aesthetics

- `x`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `bins`: number of bins or a vector of bin edges
- `binwidth`: width of each bin (alternative to bins)
- `center`: value that should be at the center of a bin (useful for discrete data)
- `boundary`: value that should be at the edge of a bin
- `normalization`
- `color` / `colour`
- `stroke` / `strokewidth`
- `strokecolor` / `strokecolour`

# Examples

```julia
penguins = penguins_data()

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram()

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization=:probability, bins=20)

# For discrete/integer data, use center to align bars with tick marks
# This centers a bin on 0, so tick marks appear at bar centers
ggplot(df, @aes(x = counts)) +
    geom_histogram(binwidth=1, center=0)
```
"""
geom_histogram = geom_template("geom_histogram", ["x"], :Hist;
    grouping_aes=[:color, :colour],
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ))

@testitem "geom_hist" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_histogram(@aes(x = bill_length_mm))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Hist,
              penguins.bill_length_mm)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

  end