using TidierPlots
using Test
using DataFrames
using Makie
using TidierData
using Images
using Parquet2
using CategoricalArrays
using GLM
using Loess
using KernelDensity
using Colors
using ColorSchemes
using Format
using Dates
using Random

# functions to compare two images using a difference hash
# essentially copied from ImageHashes.jl, but package is out of date

include("difference_hash.jl")

# load the penguins dataset

penguins = DataFrame(Parquet2.readfile(joinpath(@__DIR__, "penguins.parq")))

# configure TidierPlots to not show the plot and not output logs

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)
TidierPlots_set("plot_pluto", false)
TidierPlots_set("verbose", false)

# configure Makie to use the ggplot2 theme

set_theme!(theme_ggplot2())

# see files for tests
@testset "TidierPlots" verbose = true begin
    @test_throws ArgumentError TidierPlots_set("na", true)
    @info "Testing aes specifications..."
    include("test_aes.jl")
    @info "Testing aes operations..."
    include("test_aes_ops.jl")
    @info "Testing broadcasting..."
    include("test_broadcasting.jl")
    @info "Testing conversions..."
    include("test_conversions.jl")
    @info "Testing data specification..."
    include("test_data.jl")
    @info "Testing aes extraction..."
    include("test_extract_aes.jl")
    @info "Testing facets..."
    include("test_facets.jl")
    @info "Testing geoms..."
    include("test_geoms.jl")
    @info "Testing geom options..."
    include("test_geom_options.jl")
    @info "Testing ggsave..."
    include("test_ggsave.jl")
    @info "Testing labs..."
    include("test_labs.jl")
    @info "Testing labelling functions..."
    include("test_label_functions.jl")
    @info "Testing legends..."
    include("test_legend.jl")
    @info "Testing plot limits..."
    include("test_lims.jl")
    @info "Testing patchwork..."
    include("test_patchwork.jl")
    @info "Testing color scales..."
    include("test_scale_colour.jl")
    @info "Testing non-color scales..."
    include("test_scales.jl")
    @info "Testing themes..."
    include("test_themes.jl")
    @info "Testing documentation..."
    include("test_docs_will_render.jl")
    @info "Testing issue regressions..."
    include("test_issue_reg.jl")
end
