# TidierPlots.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/TidierOrg/Tidier.jl/blob/main/LICENSE)

## What is TidierPlots.jl?

Tidier.jl is a 100% Julia implementation of the R package ggplot in Julia. Powered by the AlgebraOfGraphics.jl, Makie.jl, and Julia’s
extensive meta-programming capabilities, TidierPlots.jl is an R user’s love
letter to data visualization in Julia.

`TidierPlots.jl` has three goals, which differentiate it from other data analysis
meta-packages in Julia:

1.  **Stick as closely to tidyverse syntax as possible:** Whereas other
    meta-packages introduce Julia-centric idioms for working with
    plots, this package’s goal is to reimplement ggplot
    in Julia. This means that `TidierPlots.jl` uses *tidy expressions* as opposed
    to idiomatic Julia expressions. An example of a tidy expression is
    `a = mean(b)`.

2.  

3.  

## Installation

For the development version:

```julia
using Pkg
Pkg.add(url="https://github.com/TidierOrg/TidierPlots.jl")
```

## What functions does TidierPlots.jl support?

To support R-style programming, TidierPlots.jl is implemented using macros.

TidierPlots.jl currently supports the following top-level macros:

- `@ggplot()`
- `@geom_point()`
- `@geom_smooth()`

## Example

Let's make a plot using the Palmer Penguins data from `PalmerPenguins.jl`:

```julia
using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

test_plot = @ggplot(data = penguins, aes(color = species)) + 
    @geom_point(aes(x = bill_length_mm, y = bill_depth_mm)) + 
    @geom_smooth(aes(x = bill_length_mm, y = bill_depth_mm), method = "lm")

draw_ggplot(test_plot)
```

![](assets/example.png)