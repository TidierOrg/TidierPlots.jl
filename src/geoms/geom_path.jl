function stat_sort_by_x(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T, Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    perm = sortperm(plot_data[!, :x])

    return (aes_dict, args_dict, required_aes, plot_data[perm, :])
end

"""
    geom_line(aes(...), ...)
    geom_line(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order of the variable on the x-axis.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_line()
```
"""
geom_line = geom_template("geom_line", ["x", "y"], :Lines;
    post_function = stat_sort_by_x,
    grouping_aes = [:color, :colour]
)

@testitem "geom_line" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_line(@aes(x = bill_length_mm, y = bill_depth_mm))

    perm = sortperm(penguins.bill_length_mm)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Lines,
              penguins.bill_length_mm[perm],
              penguins.bill_depth_mm[perm])
          ]
        )
      )
    )

    @test plot_images_equal(t, m)
  end

"""
    geom_step(aes(...), ...)
    geom_step(plot::GGPlot, aes(...), ...)

Represents data as a stairstep plot.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Stairs)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_step()
```
"""
geom_step = geom_template("geom_step", ["x", "y"], :Stairs;
    post_function = stat_sort_by_x,
    grouping_aes = [:color, :colour]
)

@testitem "geom_step" setup=[TidierPlotsSetup] begin
    xs = collect(rand(30) * 2pi)
    df = DataFrame(x=xs, y=sin.(xs))

    perm = sortperm(df.x)

    t = ggplot(df, @aes(x = x, y = y)) + geom_step()

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Stairs,
              df.x[perm],
              df.y[perm])
          ]; xlabel="x", ylabel="y"
        )
      )
    )

    @test plot_images_equal(t, m)
  end

"""
    geom_path(aes(...), ...)
    geom_path(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order in which they appear in the data.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path()
```
"""
geom_path = geom_template("geom_path", ["x", "y"], :Lines;
    grouping_aes = [:color, :colour])

    @testitem "geom_path" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_path(@aes(x = bill_length_mm, y = bill_depth_mm))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Lines,
              penguins.bill_length_mm,
              penguins.bill_depth_mm)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)
  end