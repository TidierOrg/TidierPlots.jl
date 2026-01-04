"""
    geom_ribbon(aes(...), ...)
    geom_ribbon(plot::GGPlot, aes(...), ...)

Displays a filled area between ymin and ymax.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Band)

# Required Aesthetics

- `x`
- `ymin`
- `ymax`

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
df = DataFrame(x = xs, lower = sin.(xs) .- 0.5, upper = sin.(xs) .+ 0.5)

ggplot(df, @aes(x = x, ymin = lower, ymax = upper)) + geom_ribbon()
```
"""
function handle_ribbon(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    # Band expects x, lower, upper - rename ymin/ymax to lower/upper
    new_aes_dict = Dict{Symbol,Pair}()

    for (k, v) in aes_dict
        if k == :ymin
            new_aes_dict[:lower] = v
        elseif k == :ymax
            new_aes_dict[:upper] = v
        else
            new_aes_dict[k] = v
        end
    end

    return (new_aes_dict, args_dict, ["x", "lower", "upper"], plot_data)
end

geom_ribbon = geom_template("geom_ribbon", ["x", "ymin", "ymax"], :Band;
    pre_function = handle_ribbon,
    special_aes = Dict(:fill => :color),
    grouping_aes = [:color, :colour, :fill])

@testitem "geom_ribbon" setup = [TidierPlotsSetup] begin
    xs = collect(range(0, 2pi, length=30))
    df_ribbon = DataFrame(x = xs, ymin = sin.(xs) .- 0.5, ymax = sin.(xs) .+ 0.5)

    t = ggplot(df_ribbon, @aes(x = x, ymin = ymin, ymax = ymax)) + geom_ribbon()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_ribbon(ggplot(df_ribbon), @aes(x = x, ymin = ymin, ymax = ymax))
    @test plot_will_render(t2)
end