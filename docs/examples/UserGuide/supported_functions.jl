using TidierPlots
using DataFrames
using PalmerPenguins
using WGLMakie

# ## @geom_bar, @labs
WGLMakie.activate!()
penguins = dropmissing(DataFrame(PalmerPenguins.load()))
ggplot(data = penguins) + 
    geom_bar(@aes(x = species)) +
    labs(x = "Species")