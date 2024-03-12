using TidierPlots
using Test
using DataFrames
using Makie
using TidierData
using ImageHashes, Images
using Chain
using JDF
using CategoricalArrays

# load the penguins dataset

penguins = DataFrame(JDF.load(joinpath(@__DIR__, "penguins.jdf")))

# configure TidierPlots to not show the plot and not output logs

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)

# configure Makie to use the ggplot2 theme

set_theme!(theme_ggplot2())

# function to compare two images using a hash

function plot_images_equal(tidier, makie)
    tidierpath = tempname() * ".png"
    makiepath = tempname() * ".png"

    ggsave(tidierpath, tidier)
    save(makiepath, makie)

    t_img = load(tidierpath)
    m_img = load(makiepath)
    
    return difference_hash(t_img) == difference_hash(m_img)
end

# see files for tests

include("test_aes.jl")
include("test_geoms.jl")
include("test_labs.jl")
include("test_lims.jl")
