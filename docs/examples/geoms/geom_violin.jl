using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin()

md"""
Unlike in `ggplot2`, you cannot put the categorical variable on the `y`-axis:

```julia
# This causes unexpected output
ggplot(penguins) +
    geom_violin(@aes(x = bill_length_mm, y = species))
```

Instead you can pass `orientation = :horizontal` as an optional argument:
"""

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_violin(orientation = :horizontal)

#-

ggplot(penguins, @aes(x=species, y=bill_length_mm, dodge=sex, color=sex)) +
    geom_violin()
