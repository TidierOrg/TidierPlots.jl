using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

ggplot(penguins) +
    geom_histogram(@aes(x = bill_length_mm))
