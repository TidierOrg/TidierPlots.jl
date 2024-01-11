```@meta
EditURL = "../../../../examples/UserGuide/supported_functions.jl"
```

````@example supported_functions
using TidierPlots
using DataFrames
using PalmerPenguins
using WGLMakie
````

## @geom_bar, @labs

````@example supported_functions
WGLMakie.activate!()
penguins = dropmissing(DataFrame(PalmerPenguins.load()))
ggplot(data = penguins) +
    geom_bar(@aes(x = species)) +
    labs(x = "Species")
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

