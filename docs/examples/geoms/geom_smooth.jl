using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

xs = range(0, 2pi, length=30)
ys = sin.(xs) .+ randn(length(xs)) * 0.5
df = DataFrame(x = xs, y = ys)

ggplot(df, @aes(x = x, y = y)) + geom_smooth() + geom_point()

#-

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_smooth(color=:red, linewidth=10, alpha=0.5)
