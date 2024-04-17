using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

ggplot(penguins) +
    geom_col(@aes(x = species, y = bill_length_mm))
