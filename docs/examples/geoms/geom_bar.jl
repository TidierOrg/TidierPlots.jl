using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

# vertical bar plot
ggplot(penguins) + geom_bar(@aes(x = species))

# horizontal bar plot
ggplot(penguins) + geom_bar(@aes(y = species))

# stacked
ggplot(penguins, @aes(x = species, fill=sex)) + geom_bar()

# dodged
ggplot(penguins, @aes(x = species, fill=sex, dodge = sex)) + geom_bar()
