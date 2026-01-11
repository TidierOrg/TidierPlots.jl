function stat_contour(
  aes_dict,
  args_dict,
  required_aes::Vector{String},
  plot_data::DataFrame,
)
  if !haskey(aes_dict, :x) || !haskey(aes_dict, :y)
    ArgumentError("geom_density_2d requires x and y aesthetics")
  end

  x = plot_data[!, :x]
  y = plot_data[!, :y]
  if all(x .== y)
    @warn "Equal x and y aesthetics detected. This may not be intended."
  end
  x_range = (minimum(x), maximum(x))
  y_range = (minimum(y), maximum(y))
  estimates_list = []

  unique_groups = unique(plot_data[!, :group])
  for group in unique_groups
    group_indices = plot_data[!, :group] .== group
    x_group = x[group_indices]
    y_group = y[group_indices]
    estimates = KernelDensity.kde((x_group, y_group); boundary=(x_range, y_range))
    push!(estimates_list, (group, estimates))
  end

  x̂ = reduce(vcat, [repeat(estimates.x, length(estimates.y)) for (_, estimates) in estimates_list])
  ŷ = reduce(vcat, [repeat(estimates.y, inner=length(estimates.x)) for (_, estimates) in estimates_list])
  ẑ = reduce(vcat, [vec(estimates.density) for (_, estimates) in estimates_list])
  group = reduce(vcat, [fill(group, length(estimates.x) * length(estimates.y)) for (group, estimates) in estimates_list])

  return_data = DataFrame(
    :x => x̂,
    :y => ŷ,
    :z => ẑ,
    :group => group
  )


  if !haskey(aes_dict, :z)
    push!(aes_dict, :z => :z => identity)
  end
  if "z" ∉ required_aes
    push!(required_aes, "z")
  end
  return (aes_dict, args_dict, required_aes, return_data)
end


geom_density_2d = geom_template("geom_density_2d", ["x", "y"], :Contour;
  grouping_aes=[:linestyle, :color, :colour],
  post_function=stat_contour
)

geom_density2d = geom_density_2d

geom_contour = geom_density_2d


geom_density_2d_filled = geom_template("geom_density_2d_filled", ["x", "y"], :Contourf;
  grouping_aes=[:color, :colour],
  post_function=stat_contour
)
geom_density2d_filled = geom_density_2d_filled

geom_contour_filled = geom_density_2d_filled


"""
    geom_density_2d(aes(...), ...)
    geom_density_2d(plot::GGPlot, aes(...), ...)

    geom_density2d(aes(...), ...)
    geom_density2d(plot::GGPlot, aes(...), ...)

    geom_contour(aes(...), ...)
    geom_contour(plot::GGPlot, aes(...), ...)

Represent data as a 2D density contour using 2D kernel density estimation.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Density)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `strokewidth` / `stroke`
- `linestyle` / `linetype`
- `alpha`
- `group`

# Optional Arguments

- `breaks` / `levels`

# Examples

```julia
penguins = penguins_data()

ggplot(penguins, @aes(x=bill_length_mm, y=bill_depth_mm)) +
    geom_density_2d()

ggplot(penguins, @aes(x=bill_length_mm, y=bill_depth_mm)) +
    geom_density_2d(color = :black, stroke = 2)
```
See also [`geom_contour_filled`](@ref) and [`geom_density_2d_filled`](@ref) for similar geoms.
"""
geom_density_2d, geom_density2d, geom_contour

"""
    geom_density_2d_filled(aes(...), ...)
    geom_density_2d_filled(plot::GGPlot, aes(...), ...)

    geom_density2d_filled(aes(...), ...)
    geom_density2d_filled(plot::GGPlot, aes(...), ...)

    geom_contour_filled(aes(...), ...)
    geom_contour_filled(plot::GGPlot, aes(...), ...)

Represent data as a filled 2D density contour using 2D kernel density estimation.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Density)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `alpha`
- `group`

# Optional Arguments

- `breaks` / `levels`

# Examples

```julia
penguins = penguins_data()

ggplot(penguins, @aes(x=bill_length_mm, y=bill_depth_mm)) +
    geom_density_2d_filled()

ggplot(penguins, @aes(x=bill_length_mm, y=bill_depth_mm)) +
    geom_density_2d_filled(color = :black, stroke = 2)
```
# See also [`geom_contour`](@ref) and [`geom_density_2d`](@ref) for similar geoms.
"""
geom_density_2d_filled, geom_density2d_filled, geom_contour_filled

 @testitem "geom_contour" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_contour()
    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d.x,
              d.y,
              d.z;
            )
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )
    @test plot_images_equal(t, m)
  end

  @testitem "geom_contour_filled" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_contour_filled()
    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contourf,
              d.x,
              d.y,
              d.z;
              levels=10)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )
    @test plot_images_equal(t, m)
  end


  @testitem "geom_density_2d" setup = [TidierPlotsSetup] begin
    ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_density2d(breaks=10)
    @test_throws ArgumentError TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity
      ),
      Dict(),
      ["x"],
      @chain penguins begin
        @rename(x = bill_length_mm)
      end
    )

    @test_warn "Equal x and y aesthetics detected. This may not be intended." TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_length_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @mutate(x = bill_length_mm, y = bill_length_mm, group = 1)
      end
    )


    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_density_2d(breaks=10)

    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d.x,
              d.y,
              d.z;
              levels=10)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t, m)


    t2 = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, group = species)) +
         geom_density_2d()

    ae2, ar2, r2, d2 = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm, group = species)
      end
    )

    m2 = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d2.x[d2.group.==g],
              d2.y[d2.group.==g],
              d2.z[d2.group.==g],
            ) for g in unique(d2.group)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t2, m2)

  end


  @testitem "geom_density_2d_filled" setup = [TidierPlotsSetup] begin
    ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_density2d_filled()

    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_density_2d_filled()

    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contourf,
              d.x,
              d.y,
              d.z)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )


    @test plot_images_equal(t, m)

  end