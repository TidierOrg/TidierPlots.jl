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
    @info "Saving AlgebraOfGraphics plot..."
    save(aogpath, draw(aog; axis = (height = 400, width = 600,)); px_per_unit = 1)

    @info "Loading TidierPlot..."
    t_img = load(tidierpath)
    @info "Loading AlgebraOfGraphics plot..."
    a_img = load(aogpath)
    
    @info "Hashing TidierPlot..."
    t_hash = difference_hash(t_img)
    @info "Done. Hash: $t_hash"
    @info "Hashing AlgebraOfGraphics plot..."
    a_hash = difference_hash(a_img)
    @info "Done. Hash: $a_hash"

    return a_hash == t_hash
end

@testset "geoms" begin
    @test plot_images_equal(
        ggplot(penguins) + 
            geom_bar(@aes(x = species)) +
            labs(x = "Species"),
        data(penguins) * 
            mapping(:species) *
            frequency() *
            visual(BarPlot)
    )
    @test plot_images_equal(
        ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
            geom_smooth(method = "lm"),
        data(penguins) *
            mapping(:bill_length_mm, :bill_depth_mm, color = :species) * 
            linear()        
    )
    @test plot_images_equal(
        ggplot(penguins, @es(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
            geom_point(),
        data(penguins) * 
            mapping(:bill_length_mm, :bill_depth_mm, color = :species) * 
            visual(Scatter)
    )
    @test plot_images_equal(
        ggplot(penguins, aes(x = :bill_length_mm, y = :bill_depth_mm)) + 
            geom_point(shape = :diamond, 
                size = 20, 
                stroke = 1, 
                strokecolour = "black",
                alpha = 0.8),
        data(penguins) *
            mapping(:bill_length_mm, :bill_depth_mm) *
            visual(Scatter; 
                marker = :diamond,
                markersize = 20, 
                strokewidth = 1,
                strokecolor = :black,
                alpha = 0.8)
    )
    @test plot_images_equal(
        ggplot(penguins, aes(x = "species", y = "bill_depth_mm")) +
            geom_violin(),
        data(penguins) *
            mapping(:species, :bill_depth_mm) *
            visual(Violin)
    )
    @test plot_images_equal(
        ggplot(penguins, aes(x = "species", y = "bill_depth_mm")) +
            geom_boxplot(),
        data(penguins) *
            mapping(:species, :bill_depth_mm) *
            visual(BoxPlot)
    )
    @test plot_images_equal(
        ggplot(penguins, aes(x = "bill_length_mm",
                             y = "bill_depth_mm",
                             colour = "species")) +
            geom_contour(),
        data(penguins) *
            density() *
            visual(Contour) *
            mapping(:bill_length_mm, :bill_depth_mm, color = :species)
    )
    
end

@testset "piping" begin
    chainplot = @chain penguins begin
        ggplot(aes(x = "species", y = "bill_depth_mm"))
        geom_violin()
    end
    
    @test plot_images_equal(
        chainplot,
        data(penguins) *
            mapping(:species, :bill_depth_mm) *
            visual(Violin)
    )
end