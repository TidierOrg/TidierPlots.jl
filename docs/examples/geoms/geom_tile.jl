using TidierPlots
using DataFrames

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
