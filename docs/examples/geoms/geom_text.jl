using TidierPlots
using DataFrames

df = DataFrame(
    x = [1,1,2,2],
    y = [1,2,1,2],
    t = ["A", "B", "C", "D"]
)

md"""
## geom_text
"""

ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_text()

#-

ggplot(df, @aes(x=x, y=y, text=t, color=t)) +
    geom_text(fontsize=24, align=(:left, :bottom), font=:bold) +
    geom_point() +
    lims(x = (0, 3), y = (0, 3))

md"""
## geom_label

!!! warning "ggplot2 deviation"
    Currently this method is the same as [`geom_text`](@ref), and does not put the text in
    a rectangle like in `ggplot2`.
"""

ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_label()

#-

ggplot(df, @aes(x=x, y=y, text=t, color=t)) +
    geom_label(fontsize=24, align=(:left, :bottom), font=:bold) +
    geom_point() +
    lims(x = (0, 3), y = (0, 3))
