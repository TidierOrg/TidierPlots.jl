using TidierPlots
using Test
using PalmerPenguins
using DataFrames
using Makie: Text, Violin, 
    BarPlot, Contour, Heatmap, Rangebars, BoxPlot,
    HLines, VLines, Lines, Stairs, Scatter,
    set_theme!
using AlgebraOfGraphics
using ImageHashes, Images
using Chain

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)

set_theme!(theme_ggplot2())

function plot_images_equal(tidier, aog)
    @info "Getting temporary paths..."
    tidierpath = tempname() * ".png"
    aogpath = tempname() * ".png"

    @info "Saving TidierPlot..."
    ggsave(tidierpath, tidier; scale = 1)
    @info "Saving Makie plot..."
    save(aogpath, draw(aog; axis = (height = 400, width = 600,)); px_per_unit = 1)

    @info "Loading TidierPlot..."
    t_img = load(tidierpath)
    @info "Saving Makie plot..."
    a_img = load(aogpath)
    
    @info "Hashing TidierPlot..."
    t_hash = difference_hash(t_img)
    @info "Done. Hash: $t_hash"
    @info "Saving Makie plot..."
    a_hash = difference_hash(a_img)
    @info "Done. Hash: $a_hash"

    return a_hash == t_hash
end

@testset fake begin
    1 == 1
end