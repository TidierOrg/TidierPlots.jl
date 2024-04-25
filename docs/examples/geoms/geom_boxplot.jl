using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

#-

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot()

md"""
Unlike in `ggplot2`, you cannot put the categorical variable on the `y`-axis:

```julia
# This causes unexpected output
ggplot(penguins) +
    geom_boxplot(@aes(x = bill_length_mm, y = species))
```

Instead you can pass `orientation = :horizontal` as an optional argument:
"""

ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
    geom_boxplot(orientation = :horizontal)

#-

ggplot(penguins, @aes(x=species, y=bill_length_mm, dodge=sex, color=sex)) +
    geom_boxplot()
