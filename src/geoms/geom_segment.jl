function handle_segment(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    # Makie.linesegments expects points as consecutive pairs: [p1, p2, p3, p4, ...]
    # where segments are p1-p2, p3-p4, etc.
    # We need to interleave (x, y) and (xend, yend) for each row

    n = nrow(plot_data)
    new_x = Vector{Any}(undef, 2n)
    new_y = Vector{Any}(undef, 2n)

    x_col = aes_dict[:x][1]
    y_col = aes_dict[:y][1]
    xend_col = aes_dict[:xend][1]
    yend_col = aes_dict[:yend][1]

    x_func = aes_dict[:x][2]
    y_func = aes_dict[:y][2]
    xend_func = aes_dict[:xend][2]
    yend_func = aes_dict[:yend][2]

    for i in 1:n
        new_x[2i-1] = x_func(plot_data[i, x_col])
        new_y[2i-1] = y_func(plot_data[i, y_col])
        new_x[2i] = xend_func(plot_data[i, xend_col])
        new_y[2i] = yend_func(plot_data[i, yend_col])
    end

    # Duplicate other columns for the interleaved format
    new_data = DataFrame(x = new_x, y = new_y)

    # Copy and duplicate other columns (for color, linewidth, etc.)
    for col in names(plot_data)
        if col in String.([x_col, y_col, xend_col, yend_col])
            continue
        end
        new_data[!, col] = repeat(plot_data[!, col], inner=2)
    end

    # Update aes_dict to only use x and y
    new_aes_dict = Dict{Symbol,Pair}()
    new_aes_dict[:x] = :x => identity
    new_aes_dict[:y] = :y => identity

    # Copy over other aesthetics (color, linewidth, etc.)
    for (k, v) in aes_dict
        if k in [:x, :y, :xend, :yend]
            continue
        end
        new_aes_dict[k] = v
    end

    

    return (new_aes_dict, args_dict, ["x", "y"], new_data)
end

"""
    geom_segment(aes(...), ...)
    geom_segment(plot::GGPlot, aes(...), ...)

Draws line segments between pairs of points.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.LineSegments)

# Required Aesthetics

- `x`: x-coordinate of segment start
- `y`: y-coordinate of segment start
- `xend`: x-coordinate of segment end
- `yend`: y-coordinate of segment end

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
df = DataFrame(
    x = [1, 2, 3],
    y = [1, 2, 1],
    xend = [2, 3, 4],
    yend = [2, 1, 2]
)

ggplot(df, @aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_segment()
```
"""
geom_segment = geom_template("geom_segment", ["x", "y", "xend", "yend"], :LineSegments;
    pre_function = handle_segment,
    grouping_aes = [:color, :colour])

 @testitem "geom_segment" setup=[TidierPlotsSetup] begin
    df_segment = DataFrame(
      x = [1, 2, 3],
      y = [1, 2, 1],
      xend = [2, 3, 4],
      yend = [2, 1, 2]
    )

    t = ggplot(df_segment, @aes(x = x, y = y, xend = xend, yend = yend)) +
        geom_segment() + labs(x = "", y = "")

    # Makie's LineSegments expects interleaved points: [start1, end1, start2, end2, ...]
    x_interleaved = Float64[1, 2, 2, 3, 3, 4]
    y_interleaved = Float64[1, 2, 2, 1, 1, 2]

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :LineSegments,
              x_interleaved,
              y_interleaved; color = :black)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    # Test alternative syntax with geom receiving plot
    t2 = geom_segment(ggplot(df_segment), @aes(x = x, y = y, xend = xend, yend = yend)) + labs(x = "", y = "")

    @test plot_images_equal(t, t2)
  end