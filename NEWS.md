# TidierPlots.jl updates

# v0.6.0 - 2024-02-27
- Dependency on AlgebraOfGraphics.jl removed
- Support for positional aes specification (e.g. @aes(x, y) instead of @aes(x = x, y = y))
- Support for horizontal bars in geom_bar and geom_col
- All Makie plotting arguments are supported via passthrough (as either aes or args)
- Breaks: geom_smooth, geom_contour, facet_wrap, facet_grid, all tests

# v0.5.5 - 2024-02-20
- Bug fix: Documentation now deploys correctly
- Documentation has been expanded to include an initial "How To" section
- Bug fix: geom_hline() and geom_vline() now work as expected
- Bug fix: linewidth option for geom_line() now works

# v0.5.4 - 2024-01-25
- Bug fix: geom_density now works in Julia v1.10
- Bug fix: plots now display inside of Pluto.jl

# v0.5.3 - 2023-11-28
- Bug fix: `labs()` and themes work with piping interface
- Added Chain as dependency and re-export `@chain` - this will make it easier to use the piping interface.

# v0.5.2
- Function-based interface has completely replaced the macro-based interface. 