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
    include("test_aes.jl")
    include("test_aes_ops.jl")
    include("test_broadcasting.jl")
    include("test_conversions.jl")
    include("test_data.jl")
    include("test_extract_aes.jl")
    include("test_geoms.jl")
    include("test_geom_options.jl")
    include("test_ggsave.jl")
    include("test_labs.jl")
    include("test_label_functions.jl")
    include("test_legend.jl")
    include("test_lims.jl")
    include("test_patchwork.jl")
    include("test_scale_colour.jl")
    #include("test_docs_will_render.jl")
end
