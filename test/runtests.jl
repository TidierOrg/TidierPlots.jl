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

    penguins = DataFrame(Parquet2.readfile(joinpath(@__DIR__, "penguins.parq")))

    # configure TidierPlots to not show the plot and not output logs

    TidierPlots_set("plot_show", false)
    TidierPlots_set("plot_log", false)
    TidierPlots_set("plot_pluto", false)
    TidierPlots_set("verbose", false)

    # configure Makie to use the ggplot2 theme

    set_theme!(theme_ggplot2())

end

# see files for tests

@testitem "Conversions" setup=[TidierPlotsSetup] begin
    include("test_conversions.jl")
end
@testitem "Data specification" setup=[TidierPlotsSetup] begin
    include("test_data.jl")
end
@testitem "Aes extraction" setup=[TidierPlotsSetup] begin
    include("test_extract_aes.jl")
end
@testitem "Geoms" setup=[TidierPlotsSetup] begin
    include("test_geoms.jl")
end
@testitem "Geom options" setup=[TidierPlotsSetup] begin
    include("test_geom_options.jl")
end
@testitem "GGsave" setup=[TidierPlotsSetup] begin
    include("test_ggsave.jl")
end
@testitem "labs" setup=[TidierPlotsSetup] begin
    include("test_labs.jl")
end
@testitem "Labelling functions" setup=[TidierPlotsSetup] begin
    include("test_label_functions.jl")
end
@testitem "Legends" setup=[TidierPlotsSetup] begin
    include("test_legend.jl")
end
@testitem "Plot limits" setup=[TidierPlotsSetup] begin
    include("test_lims.jl")
end
@testitem "Patchwork" setup=[TidierPlotsSetup] begin
    include("test_patchwork.jl")
end
@testitem "Color scales" setup=[TidierPlotsSetup] begin
    include("test_scale_colour.jl")
end
@testitem "Non-color scales" setup=[TidierPlotsSetup] begin
    include("test_scales.jl")
end
@testitem "Themes" setup=[TidierPlotsSetup] begin
    include("test_themes.jl")
end
@testitem "Documentation" setup=[TidierPlotsSetup] begin
    include("test_docs_will_render.jl")
end
@testitem "Issue regressions" setup=[TidierPlotsSetup] begin
    include("test_issue_reg.jl")
end
