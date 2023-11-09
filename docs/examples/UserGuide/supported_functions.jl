using TidierPlots
using DataFrames
using PalmerPenguins
using WGLMakie

WGLMakie.activate!()

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

# ## @geom_bar, @labs
ggplot(data = penguins) + 
    geom_bar(@aes(x = species)) +
    labs(x = "Species")