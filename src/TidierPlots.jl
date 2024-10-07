module TidierPlots

# CairoMakie, the default backend for Makie
using CairoMakie

# DataFrames are the main supported data type
using DataFrames

# to reexport the Makie default themes
using Reexport

# Needed for color scales to work correctly
using Colors
using ColorSchemes
using FixedPointNumbers

# Needed for label functions
using Format
using Dates

# For handling categorical data types
using CategoricalArrays
using PooledArrays

# Data manipulation, expression parsing
using TidierData

# for geom_smooth fits
using GLM
using Loess

# for geom_contour fits
using KernelDensity

include("structs.jl")

include("addplots.jl")
include("aes.jl")
include("attributes.jl")
include("broadcasting.jl")
include("convert.jl")
include("draw.jl")
include("extract_aes.jl")
include("facets.jl")
include("geom.jl")
include("ggplot.jl")
include("ggsave.jl")
include("labs.jl")
include("label_functions.jl")
include("legend.jl")
include("patchwork.jl")
include("scales_colour.jl")
include("scales_numeric.jl")
include("themes.jl")
include("show.jl")
include("util.jl")

include("geoms/geom_template.jl")

include("geoms/geom_bar.jl")
include("geoms/geom_boxplot.jl")
include("geoms/geom_density.jl")
include("geoms/geom_errorbar.jl")
include("geoms/geom_hvline.jl")
include("geoms/geom_hist.jl")
include("geoms/geom_path.jl")
include("geoms/geom_point.jl")
include("geoms/geom_smooth.jl")
include("geoms/geom_text.jl")
include("geoms/geom_tile.jl")
include("geoms/geom_violin.jl")

# theming

@reexport using Makie: theme_black, theme_dark, theme_ggplot2, theme_light, theme_minimal
export theme

# functions

export draw_ggplot, ggplot, ggsave
export TidierPlots_set
export @aes, @es, aes
export geom_template
export plot_layout

# geoms

export geom_bar
export geom_col
export geom_histogram
export geom_point
export geom_path
export geom_line
export geom_step
export geom_smooth
export geom_errorbar
export geom_errorbarh
export geom_violin
export geom_boxplot
export geom_contour
export geom_tile
export geom_text
export geom_label
export geom_density
export geom_hline
export geom_vline

# facetting

export facet_wrap, facet_grid

# scales

export labs, lims, c
export label_bytes, label_currency, label_date, label_log, label_number, label_ordinal, label_percent, label_pvalue, label_scientific, label_wrap
export scale_x_continuous, scale_y_continuous
export scale_x_log10, scale_y_log10, scale_x_log2, scale_y_log2, scale_x_log, scale_y_log
export scale_x_logit, scale_y_logit
export scale_x_pseudolog10, scale_y_pseudolog10, scale_x_symlog10, scale_y_symlog10
export scale_x_reverse, scale_y_reverse, scale_x_sqrt, scale_y_sqrt
export scale_colour_continuous, scale_colour_discrete, scale_colour_manual, scale_colour_binned
export scale_color_continuous, scale_color_discrete, scale_color_manual, scale_color_binned
export scale_fill_continuous, scale_fill_discrete, scale_fill_manual, scale_fill_binned

# default options

const plot_log = Ref{Bool}(true)
const plot_show = Ref{Bool}(true)
const plot_pluto = Ref{Bool}(true)

end
