using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point()

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_point(@aes(color = sex), size=20, stroke=1, alpha=0.6)
