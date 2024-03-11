using TidierPlots
using Test
using DataFrames
using Makie
using TidierData
using ImageHashes, Images
using Chain
using JDF
using CategoricalArrays

penguins = DataFrame(JDF.load(joinpath(@__DIR__, "penguins.jdf")))

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)

set_theme!(theme_ggplot2())

function plot_images_equal(tidier, makie)
    tidierpath = tempname() * ".png"
    makiepath = tempname() * ".png"

    ggsave(tidierpath, tidier)
    save(makiepath, makie)

    t_img = load(tidierpath)
    m_img = load(makiepath)
    
    return difference_hash(t_img) == difference_hash(m_img)
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

@testset "geom_bar-basic" begin
    t = ggplot(penguins) + 
        geom_bar(@aes(x = species))

    penguins_count = @chain penguins begin
        groupby(:species)
        @summarize(count = n())
        @arrange(species)
    end
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :BarPlot, 
                        penguins_count.count)
                ]; xticks = (1:3, penguins_count.species)
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

@testset "geom_line-basic" begin
    t = ggplot(penguins) + 
        geom_line(@aes(x = bill_length_mm, y = bill_depth_mm))
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Lines, 
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

