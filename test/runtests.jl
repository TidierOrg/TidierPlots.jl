using TidierPlots
using Test
using PalmerPenguins
using DataFrames
using Makie
using ImageHashes, Images
using Chain

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)

set_theme!(theme_ggplot2())

function plot_images_equal(tidier, makie)
    @info "Getting temporary paths..."
    tidierpath = "file1" * ".png"
    makiepath = "file2" * ".png"

    @info "Saving TidierPlot..."
    ggsave(tidierpath, tidier)
    @info "Saving Makie plot..."
    save(makiepath, makie)

    @info "Loading TidierPlot..."
    t_img = load(tidierpath)
    @info "Loading Makie plot..."
    m_img = load(makiepath)
    
    @info "Hashing TidierPlot..."
    t_hash = difference_hash(t_img)
    @info "Done. Hash: $t_hash"
    @info "Saving Makie plot..."
    m_hash = difference_hash(m_img)
    @info "Done. Hash: $m_hash"

    return m_hash == t_hash
end

function Base.:(==)(aes1::TidierPlots.Aesthetics, aes2::TidierPlots.Aesthetics) 
    if length(aes1.positional) != 0 || length(aes2.positional) != 0
        if length(aes2.positional) != length(aes1.positional)
            return false
        end
        if any(aes1.positional .!= aes2.positional)
            return false
        end
    end

    if length(aes1.named) != 0 || length(aes2.named) != 0
        if length(aes2.named) != length(aes1.named)
            return false
        end
        if length(intersect(keys(aes1.named), keys(aes2.named))) != length(aes1.named)
            return false
        end
        for (k, v) in aes1.named
            if aes2.named[k] != v
                return false
            end
        end
    end

    return true
end

@testset "aes-equivalence" begin
    @test aes(x = "x", y = "y") == @aes(x = x, y = y) 
    @test aes(x = "x", y = "y") == @es(x = x, y = y) 
    @test aes(x = "x", y = "y") == aes(x = :x, y = :y) 
end

@testset "geom_point-basic" begin
    t = ggplot(penguins) + 
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter, 
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    
    @test plot_images_equal(t, m)
end