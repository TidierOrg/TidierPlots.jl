using TidierPlots
using Test
using PalmerPenguins
using DataFrames
using AlgebraOfGraphics
using Makie
using ImageHashes, Images

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

TidierPlots_set("autoplot", false)

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

@testset "geom_point" begin
    tidier = @ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
        @geom_point()

    aog = data(penguins) * 
        mapping(:bill_length_mm, :bill_depth_mm, color = :species) * 
        visual(Scatter)

    @test plot_images_equal(tidier, aog)
end

@testset "geom_smooth" begin
    tidier_lm = @ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
            @geom_smooth(method = "lm")

    aog_lm = data(penguins) *
        mapping(:bill_length_mm, :bill_depth_mm, color = :species) * 
        linear()

    @test plot_images_equal(tidier_lm, aog_lm)

    tidier_sm = @ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
            @geom_smooth()

    aog_sm = data(penguins) *
        mapping(:bill_length_mm, :bill_depth_mm, color = :species) * 
        smooth()

    @test plot_images_equal(tidier_sm, aog_sm)
end

@testset "geom_bar" begin
    tidier = @ggplot(data = penguins) + 
            @geom_bar(aes(x = species)) +
            @labs(x = "Species")

    aog = data(penguins) * 
        mapping(:species) *
        frequency() *
        visual(BarPlot)

    @test plot_images_equal(tidier, aog)
end
