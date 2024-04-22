using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x=bill_length_mm)) +
    geom_density()

#-

ggplot(penguins, @aes(x=bill_length_mm)) +
    geom_density(color = (:red, 0.3), strokecolor = :red, stroke = 2)
