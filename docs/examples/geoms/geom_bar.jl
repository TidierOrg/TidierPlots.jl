using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

ggplot(penguins) +
    geom_bar(@aes(x = species))
