using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

md"""
## geom_line
"""

xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_line()

md"""
## geom_path
"""

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path()

md"""
## geom_step
"""

xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_step()
