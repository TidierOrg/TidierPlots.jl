"""
    geom_polygon(aes(...), ...)
    geom_polygon(plot::GGPlot, aes(...), ...)

Draws polygons defined by x and y coordinates.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Poly)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (outline color)
- `fill` (fill color)
- `group` (to define separate polygons)

# Optional Arguments

- `color` / `colour`
- `fill`
- `strokewidth`
- `alpha`

# Examples

```julia
# Single triangle
df = DataFrame(x = [0, 1, 0.5], y = [0, 0, 1])
ggplot(df, @aes(x = x, y = y)) + geom_polygon()

# Multiple polygons using group
df = DataFrame(
    x = [0, 1, 0.5, 2, 3, 2.5],
    y = [0, 0, 1, 0, 0, 1],
    group = [1, 1, 1, 2, 2, 2]
)
ggplot(df, @aes(x = x, y = y, group = group)) + geom_polygon()
```
"""
function handle_polygon(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    # Makie.Poly expects Point2f vectors, need to convert x, y to points
    x_col = aes_dict[:x][1]
    y_col = aes_dict[:y][1]
    x_func = aes_dict[:x][2]
    y_func = aes_dict[:y][2]

    # Create points column
    plot_data = copy(plot_data)
    plot_data.points = [Point2f(x_func(x), y_func(y)) for (x, y) in zip(plot_data[!, x_col], plot_data[!, y_col])]

    new_aes_dict = Dict{Symbol,Pair}()
    new_aes_dict[:points] = :points => identity

    # Copy over other aesthetics (color, fill, group, etc.)
    for (k, v) in aes_dict
        if k in [:x, :y]
            continue
        end
        new_aes_dict[k] = v
    end

    return (new_aes_dict, args_dict, ["points"], plot_data)
end

geom_polygon = geom_template("geom_polygon", ["x", "y"], :Poly;
    pre_function = handle_polygon,
    special_aes = Dict(:fill => :color),
    grouping_aes = [:color, :colour, :fill, :group])

@testitem "geom_polygon" setup = [TidierPlotsSetup] begin
    df_polygon = DataFrame(
      x = [0.0, 1.0, 0.5],
      y = [0.0, 0.0, 1.0]
    )

    t = ggplot(df_polygon, @aes(x = x, y = y)) + geom_polygon()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_polygon(ggplot(df_polygon), @aes(x = x, y = y))
    @test plot_will_render(t2)
end