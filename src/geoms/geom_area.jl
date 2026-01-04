"""
    geom_area(aes(...), ...)
    geom_area(plot::GGPlot, aes(...), ...)

Displays a filled area from 0 to y.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Band)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (outline color)
- `fill` (fill color)

# Optional Arguments

- `color` / `colour`
- `fill`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs) .+ 1)

ggplot(df, @aes(x = x, y = y)) + geom_area()
```
"""
function handle_area(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    # Band expects x, lower, upper - create lower as 0, use y as upper
    new_aes_dict = Dict{Symbol,Pair}()

    for (k, v) in aes_dict
        if k == :y
            new_aes_dict[:upper] = v
        else
            new_aes_dict[k] = v
        end
    end

    # Add lower = 0 column to data
    plot_data = copy(plot_data)
    plot_data.lower .= 0.0
    new_aes_dict[:lower] = :lower => identity

    return (new_aes_dict, args_dict, ["x", "lower", "upper"], plot_data)
end

geom_area = geom_template("geom_area", ["x", "y"], :Band;
    pre_function = handle_area,
    special_aes = Dict(:fill => :color),
    grouping_aes = [:color, :colour, :fill])

@testitem "geom_area" setup = [TidierPlotsSetup] begin
    xs = collect(range(0, 2pi, length=30))
    df_area = DataFrame(x = xs, y = sin.(xs) .+ 1.5)

    t = ggplot(df_area, @aes(x = x, y = y)) + geom_area()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_area(ggplot(df_area), @aes(x = x, y = y))
    @test plot_will_render(t2)
end