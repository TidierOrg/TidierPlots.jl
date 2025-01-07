using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin()

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(orientation = :horizontal)

#-

ggplot(penguins, @aes(x=species, y=bill_length_mm, dodge=sex, fill=sex)) +
    geom_violin()
