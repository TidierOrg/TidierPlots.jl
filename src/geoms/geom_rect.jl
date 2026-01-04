"""
    geom_rect(aes(...), ...)
    geom_rect(plot::GGPlot, aes(...), ...)

Draws rectangles defined by corner coordinates.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Poly)

# Required Aesthetics

- `xmin`
- `xmax`
- `ymin`
- `ymax`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (outline color)
- `fill` (fill color)

# Optional Arguments

- `color` / `colour`
- `fill`
- `strokewidth`
- `alpha`

# Examples

```julia
df = DataFrame(
    xmin = [1, 3],
    xmax = [2, 4],
    ymin = [1, 2],
    ymax = [3, 4]
)

ggplot(df, @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) + geom_rect()
```
"""
function handle_rect(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    # Convert xmin, xmax, ymin, ymax to polygon vertices
    xmin_col = aes_dict[:xmin][1]
    xmax_col = aes_dict[:xmax][1]
    ymin_col = aes_dict[:ymin][1]
    ymax_col = aes_dict[:ymax][1]

    xmin_func = aes_dict[:xmin][2]
    xmax_func = aes_dict[:xmax][2]
    ymin_func = aes_dict[:ymin][2]
    ymax_func = aes_dict[:ymax][2]

    # Create a new dataframe with one row per vertex (4 vertices per rectangle)
    n = nrow(plot_data)
    new_data = DataFrame()

    x_vals = Vector{Float64}(undef, 4n)
    y_vals = Vector{Float64}(undef, 4n)
    group_vals = Vector{Int}(undef, 4n)

    for i in 1:n
        xmin = xmin_func(plot_data[i, xmin_col])
        xmax = xmax_func(plot_data[i, xmax_col])
        ymin = ymin_func(plot_data[i, ymin_col])
        ymax = ymax_func(plot_data[i, ymax_col])

        # Rectangle vertices (counter-clockwise)
        base = 4 * (i - 1)
        x_vals[base + 1] = xmin
        y_vals[base + 1] = ymin
        x_vals[base + 2] = xmax
        y_vals[base + 2] = ymin
        x_vals[base + 3] = xmax
        y_vals[base + 3] = ymax
        x_vals[base + 4] = xmin
        y_vals[base + 4] = ymax
        group_vals[base + 1:base + 4] .= i
    end

    new_data.x = x_vals
    new_data.y = y_vals
    new_data.rect_group = group_vals

    # Duplicate other columns for each vertex
    for col in names(plot_data)
        if col in [xmin_col, xmax_col, ymin_col, ymax_col]
            continue
        end
        new_data[!, col] = repeat(plot_data[!, col], inner=4)
    end

    # Create points for Poly
    new_data.points = [Point2f(x, y) for (x, y) in zip(new_data.x, new_data.y)]

    new_aes_dict = Dict{Symbol,Pair}()
    new_aes_dict[:points] = :points => identity

    # Use rect_group for grouping individual rectangles
    new_aes_dict[:group] = :rect_group => identity

    # Copy over other aesthetics (color, fill, etc.)
    for (k, v) in aes_dict
        if k in [:xmin, :xmax, :ymin, :ymax]
            continue
        end
        new_aes_dict[k] = v
    end

    return (new_aes_dict, args_dict, ["points"], new_data)
end

geom_rect = geom_template("geom_rect", ["xmin", "xmax", "ymin", "ymax"], :Poly;
    pre_function = handle_rect,
    special_aes = Dict(:fill => :color),
    grouping_aes = [:color, :colour, :fill, :group])

 @testitem "geom_rect" setup = [TidierPlotsSetup] begin
    df_rect = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0]
    )

    t = ggplot(df_rect, @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) + geom_rect()

    # First rectangle vertices
    points1 = [Point2f(1, 1), Point2f(2, 1), Point2f(2, 3), Point2f(1, 3)]
    # Second rectangle vertices
    points2 = [Point2f(3, 2), Point2f(4, 2), Point2f(4, 4), Point2f(3, 4)]

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(:Poly, points1; color=:black),
            Makie.PlotSpec(:Poly, points2; color=:black)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_rect(ggplot(df_rect), @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax))
    @test plot_images_equal(t, t2)

    # Test handle_rect direct function call
    ae, ar, r, d = TidierPlots.handle_rect(
      Dict{Symbol,Pair}(
        :xmin => :xmin => identity,
        :xmax => :xmax => identity,
        :ymin => :ymin => identity,
        :ymax => :ymax => identity
      ),
      Dict{Any,Any}(),
      ["xmin", "xmax", "ymin", "ymax"],
      df_rect
    )
    @test haskey(ae, :points)
    @test haskey(ae, :group)
    @test r == ["points"]
    @test nrow(d) == 8  # 2 rects * 4 vertices each
    #@test haskey(d, :points)
    #@test haskey(d, :rect_group)
    #@test d.rect_group[1:4] == [1, 1, 1, 1]
    #@test d.rect_group[5:8] == [2, 2, 2, 2]

    # Test with additional column that should be duplicated
    df_rect_with_extra = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0],
      label = ["A", "B"]
    )
    ae2, ar2, r2, d2 = TidierPlots.handle_rect(
      Dict{Symbol,Pair}(
        :xmin => :xmin => identity,
        :xmax => :xmax => identity,
        :ymin => :ymin => identity,
        :ymax => :ymax => identity
      ),
      Dict{Any,Any}(),
      ["xmin", "xmax", "ymin", "ymax"],
      df_rect_with_extra
    )
    @test d2.label[1:4] == ["A", "A", "A", "A"]
    @test d2.label[5:8] == ["B", "B", "B", "B"]

    # Test geom_rect with fill aesthetic
    df_rect_fill = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0],
      group = ["A", "B"]
    )
    t_fill = ggplot(df_rect_fill, @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = group)) + geom_rect()
    @test plot_will_render(t_fill)
end