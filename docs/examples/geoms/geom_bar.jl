using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

# vertical bar plot
ggplot(penguins, @aes(x = species)) +
    geom_bar()

# horizontal bar plot
ggplot(penguins, @aes(y = species)) +
    geom_bar()

# position dodge
ggplot(penguins, @aes(x = species, color=sex, dodge=sex)) +
    geom_bar()

# alternative way to dodge
ggplot(penguins, @aes(x = species, color = sex, group = sex)) +
    geom_bar(position="dodge")
