"""
    geom_density(aes(...), ...)
    geom_density(plot::GGPlot, aes(...), ...)

Represent data as a smooth density curve.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Density)

# Required Aesthetics

- `x`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `strokecolor` / `strokecolour`
- `strokewidth` / `stroke`
- `linestyle` / `linetype`
- `direction=:x`
- `npoints=200`

# Examples

```julia
penguins = penguins_data();

ggplot(penguins, @aes(x=bill_length_mm)) + geom_density()

ggplot(penguins, @aes(x=bill_length_mm)) +
    geom_density(color = :black, stroke = 2)
```
"""
geom_density = geom_template("geom_density", ["x"], :Density;
    grouping_aes=[:color, :colour, :fill, :strokecolor],
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ))

@testitem "geom_density" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins, @aes(x = body_mass_g)) +
        geom_density()

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        [Makie.SpecApi.Axis(
        plots=[
          Makie.PlotSpec(
            :Density,
            penguins.body_mass_g)]; xlabel="body_mass_g"
      )]
      )
    )

    @test plot_images_equal(t, m)

    t1 = ggplot(penguins) +
         geom_density(aes(
        x=:bill_length_mm,
        color=:sex,
        fill=:species
      ), strokewidth=1)

    t2 = ggplot(penguins) +
         geom_density(aes(
      x=:bill_length_mm,
      color=:sex,
      fill=:species
    ))

    @test plot_images_equal(t1, t2)
  end
