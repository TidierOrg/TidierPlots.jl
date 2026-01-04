"""
    geom_(aes(...), ...)
    geom_(plot::GGPlot, aes(...), ...)

Represents data as a violin plot.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Violin)

# Required Aesthetics

- `x` (integer or categorical)
- `y` (numeric)

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (used in conjunction with `dodge`)
- `dodge`

# Optional Arguments

- `orientation=:vertical`: orientation of box (`:vertical` or `:horizontal`)
- `width=1`
- `gap=0.2`
- `show_notch=false`
- `nothchwidth=0.5`
- `show_median=true`
- `dodge_gap=0.03`

# Examples

```julia
ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_violin()

ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_violin(orientation=:horizontal)

ggplot(penguins, @aes(x=species, y=bill_length_mm, fill=sex, dodge=sex)) +
    geom_violin()
```
"""
geom_violin = geom_template("geom_violin", ["x", "y"], :Violin;
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ),
    grouping_aes=[:strokecolor, :color]
)

@testitem "geom_violin" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_violin(@aes(x = species, y = bill_length_mm))

    cat_array = CategoricalArrays.CategoricalArray(penguins.species)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Violin,
              levelcode.(cat_array),
              penguins.bill_length_mm)
          ]; xticks=(unique(levelcode.(cat_array)),
            unique(cat_array))
        )
      )
    )

    @test plot_images_equal(t, m)
  end
