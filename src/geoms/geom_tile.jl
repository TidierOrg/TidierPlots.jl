"""
    geom_tile(aes(...), ...)
    geom_tile(plot::GGPlot, aes(...), ...)

Plots a heatmap as a collection of rectangles.

# Details

`x`, `y`, and `z` must all be the same length, and there must be no duplicate (x, y) pairs.
You can think of `x`, `y`, and `z` as triples of the form `(x, y, f(x, y))`.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Heatmap)

# Required Aesthetics

- `x`
- `y`
- `z`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `interpolate=false`
- `colormap` / `palette`
- `alpha`

# Examples

```julia
function mandelbrot(x, y)
    z = c = x + y*im
    for i in 1:30.0; abs(z) > 2 && return i; z = z^2 + c; end; 0
end

xs = -2:0.01:1
ys = -1.1:0.01:1.1
xys = Iterators.product(xs, ys) |> collect |> vec
zs = map(xy -> mandelbrot(xy[1], xy[2]), xys)

df = DataFrame(
    x = first.(xys),
    y = last.(xys),
    z = zs
)

ggplot(df, @aes(x = x, y = y, z = z)) + geom_tile()
```
"""
geom_tile = geom_template("geom_tile", ["x", "y", "z"], :Heatmap)
