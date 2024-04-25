using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_contour(levels = 10)
