# TidierPlots.jl updates

## v0.8.0 - 2024-09-18
- Breaking refactor, at least internally. Changes definitions of structs, replaces calculation backend
- Calculations now work in macro aes
- Fixes numerous small issues
- Plots and geoms can now be broadcast

## v0.7.3 - 2024-04-18

- `geom_boxplot` now correctly handles color as a grouping aesthetic
- automatic legend creation for color aes

## v0.7.2 - 2024-04-16

- Bug Fix: re-enables support for adding default aes outside of `ggplot()` (e.g. `ggplot() + aes(x=:x, y=:y)`)
- Bug Fix: geom args were not passing to makie by default

## v0.7.1 - 2024-04-14

- Re-enables scale_colour_*
- Bug fix in `geom_vline` and unit tests for `geom_vline` and `geom_hline` (thanks @adknudson) 

## v0.7.0 - 2024-04-12

- Fixes color scales (manual, binned, discrete, and continuous). 

## v0.6.5 - 2024-04-09

- Allow use of Julia 1.9 (1.10 is still the recommended version)

## v0.6.4 - 2024-04-08

- Bug Fix: Implementations of subtract and divide in 0.6.3 were not correct
- Functions wrapped with `aesthetics_function` can now be applied to multiple columns in aes

## v0.6.3 - 2024-04-07

- Support for `+`, `-`, `*`, and `/` inside `aes` function to specify calculated aesthetics
- Experimental support for functions applied to symbols in `aes` to allow arbitrarily complex calculated aesthetics (use `>>` operator to "pipe" the aes symbol to the function, or use `aesthetics_function(your_function::Function)` to create a version of the function that will work inside `aes` "normally", e.g. `aes(your_function(:x))`)

## v0.6.2 - 2024-04-03

- Custom labelling functions or formatting strings from Format.jl can now be passed to scales

## v0.6.1 - 2024-04-02

- Tests have been added for all currently supported geom_* functions
- Bug Fix: Repairs geoms that were broken by removal of AlgebraOfGraphics
- Basic functionality from {patchwork} (`+`, `|`, and `/` operators for plot composition) is now supported
- Column transformation functions have been standardized to allow easier declaration of new geom functions
- Support added for "compound geoms" that use more than one underlying Makie.jl plot (e.g. `geom_smooth`)
- Adds support for `stat_*` functions that modify the underlying data prior to plotting
- Adds functionality to automatically convert arguments to Types expected by Makie.jl

## v0.6.0 - 2024-02-27

- Dependency on AlgebraOfGraphics.jl removed
- Support for positional aes specification (e.g. @aes(x, y) instead of @aes(x = x, y = y))
- Support for horizontal bars in geom_bar and geom_col
- All Makie plotting arguments are supported via passthrough (as either aes or args)
- Breaks: geom_smooth, geom_contour, facet_wrap, facet_grid, all tests

## v0.5.5 - 2024-02-20

- Bug fix: Documentation now deploys correctly
- Documentation has been expanded to include an initial "How To" section
- Bug fix: geom_hline() and geom_vline() now work as expected
- Bug fix: linewidth option for geom_line() now works

## v0.5.4 - 2024-01-25

- Bug fix: geom_density now works in Julia v1.10
- Bug fix: plots now display inside of Pluto.jl

## v0.5.3 - 2023-11-28

- Bug fix: `labs()` and themes work with piping interface
- Added Chain as dependency and re-export `@chain` - this will make it easier to use the piping interface.

## v0.5.2

- Function-based interface has completely replaced the macro-based interface. 
