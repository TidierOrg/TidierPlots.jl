using Test, TestItems, TestItemRunner

@run_package_tests verbose=true

@testsnippet TidierPlotsSetup begin

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

    penguins = penguins_data()

    # configure TidierPlots to not show the plot and not output logs

    TidierPlots_set("plot_show", false)
    TidierPlots_set("plot_log", false)
    TidierPlots_set("plot_pluto", false)
    TidierPlots_set("verbose", false)

    # configure Makie to use the ggplot2 theme

    set_theme!(theme_ggplot2())

end