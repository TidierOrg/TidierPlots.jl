using TidierPlots
using Test
using DataFrames
using Makie
using TidierData
using Images
using JDF
using CategoricalArrays
using GLM
using Loess

# functions to compare two images using a difference hash
# essentially copied from ImageHashes.jl, but package is out of date

include("difference_hash.jl")

# load the penguins dataset

penguins = DataFrame(JDF.load(joinpath(@__DIR__, "penguins.jdf")))

# configure TidierPlots to not show the plot and not output logs

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)

# configure Makie to use the ggplot2 theme

set_theme!(theme_ggplot2())

# see files for tests

include("test_aes.jl")
include("test_geoms.jl")
include("test_labs.jl")
include("test_lims.jl")
