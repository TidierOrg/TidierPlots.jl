# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TidierPlots.jl is a 100% Julia implementation of R's ggplot2 package, powered by Makie.jl. It provides a grammar of graphics API that closely follows tidyverse syntax while leveraging Julia's performance and Makie's rendering capabilities.

## Common Commands

```bash
# Run all tests
julia -e 'using Pkg; Pkg.test("TidierPlots")'

# Run tests interactively (with REPL)
julia --project -e 'using Pkg; Pkg.test()'

# Build documentation locally
julia --project=docs docs/make.jl

# Activate package for development
julia --project -e 'using Pkg; Pkg.instantiate()'
```

## Architecture

### Core Data Flow

```
ggplot(data) + geom_*() + scale_*() + theme_*() → draw_ggplot() → Makie GridLayout
```

The `+` operator (in `addplots.jl`) chains components together, building up a `GGPlot` struct that holds all configuration until rendering.

### Key Data Structures (src/structs.jl)

- **GGPlot**: Main plot object containing geoms, default aesthetics, data, axis options, theme, and facet options
- **Geom**: Individual geometric layer with aesthetics, visual type (Makie plot symbol), pre/post processing functions
- **Aesthetics**: Stores column mappings as `symbol => transformation_function` pairs
- **AxisOptions**: Wraps plot options, color palettes, and legend configuration
- **FacetOptions**: Configuration for facet_grid/facet_wrap

### Module Organization

| Directory/File | Purpose |
|----------------|---------|
| `src/TidierPlots.jl` | Main module, exports all public API |
| `src/structs.jl` | All struct definitions |
| `src/draw.jl` | Core rendering via `as_GridLayout()` |
| `src/aes.jl` | `aes()` function and `@aes` macro |
| `src/extract_aes.jl` | Aesthetic extraction from data |
| `src/attributes.jl` | ggplot→Makie name mappings, type expectations |
| `src/geoms/` | All geom implementations (~30 geoms including point, bar, line, area, ribbon, density, contour, etc.) |
| `src/scales/` | Scale functions (numeric, colour, alpha, size, shape) |

### Factory Pattern for Geoms

New geoms are created using `geom_template()` in `src/geoms/geom_template.jl`:

```julia
geom_point = geom_template(
    "geom_point",           # Name for display/legend
    ["x", "y"],             # Required aesthetics
    :Scatter;               # Makie visual type symbol
    pre_function=...,       # Data transformation before drawing
    special_aes=Dict(...),  # Custom aes→makie mappings
    grouping_aes=Symbol[...]
)
```

### Attribute Translation (src/attributes.jl)

Key dictionaries that enable ggplot↔Makie translation:
- `_ggplot_to_makie`: Maps ggplot names (`:colour`, `:shape`) to Makie names (`:color`, `:marker`)
- `_makie_expected_type`: Expected types for Makie arguments
- `_legend_geom_elements`: How each geom appears in legends

### Scale System

- **Axis transforms** (`scales/numeric.jl`): `scale_x_continuous()`, log/sqrt transforms via `scale_template()`
- **Aesthetic scales** (`scales/colour.jl`, etc.): Color palettes stored in `AxisOptions.palette`

### Plot Composition (src/patchwork.jl)

Implements R's {patchwork} syntax:
- `plot1 + plot2` or `plot1 | plot2` - side by side
- `plot1 / plot2` - stacked vertically
- `plot_layout(ncol=2, nrow=2)` - grid specification

## Development Patterns

### Aesthetic Syntax Options

```julia
# Julia style
aes(x = :col1, y = :col2)
aes(x = :col1 => sqrt)              # With transformation

# R style macro (uses TidierData parsing)
@aes(x = col1, y = col2)
@aes(x = col1 / col2)               # Expressions allowed
```

### Global Settings

```julia
TidierPlots_set("plot_log", false)   # Disable printing plot specs
TidierPlots_set("plot_show", false)  # Disable auto-display
TidierPlots_set("verbose", true)     # Enable debug output
```

### Adding a New Geom

1. Create file in `src/geoms/geom_newname.jl`
2. Define pre_function if data transformation needed
3. Use `geom_template()` to create the function
4. Include in `TidierPlots.jl` and add to exports

### Type Conversions (src/convert.jl)

`convert_aes_type()` uses multiple dispatch to handle:
- Numbers → RGBA (via continuous palette)
- Strings → RGBA (via discrete palette)
- CategoricalArrays → proper encoding

## Testing

Tests use the Palmer Penguins dataset (`test/penguins.parq`). Image comparison testing uses `difference_hash.jl` for visual regression tests.

Test files are organized by feature: `test_geoms.jl`, `test_scales.jl`, `test_facets.jl`, etc.

## Dependencies

Key dependencies:
- **Makie.jl** (0.24): Underlying plotting engine
- **CairoMakie** (0.15): Default rendering backend
- **TidierData** (0.17): Used for `@aes` macro parsing
- **DataFrames** (1.7): Data handling
- **ColorSchemes** (3.24): Color palette management
- **GLM.jl**, **Loess.jl**: Statistical fitting for geom_smooth
