using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram()

#-

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization = :probability, bins = 20)
