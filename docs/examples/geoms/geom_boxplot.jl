using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_boxplot()

ggplot(penguins, @aes(y=species, x=bill_length_mm)) +
    geom_boxplot()

ggplot(penguins, @aes(x=species, y=bill_length_mm, dodge=sex, fill=sex)) +
    geom_boxplot()
