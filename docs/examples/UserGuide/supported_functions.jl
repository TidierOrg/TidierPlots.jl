using TidierPlots
using DataFrames
using PalmerPenguins
using CairoMakie

# ## @geom_bar, @labs
penguins = dropmissing(DataFrame(PalmerPenguins.load()))
ggplot(data = penguins) + 
    geom_bar(@aes(x = species)) +
    labs(x = "Species")