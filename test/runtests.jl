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

@testset "aes-equal" begin
    @test aes(x = "x", y = "y") == @aes(x = x, y = y) 
    @test aes(x = "x", y = "y") == @es(x = x, y = y) 
    @test aes(x = "x", y = "y") == aes(x = :x, y = :y) 
    @test aes("x", "y") == @aes(x, y)
    @test aes("x", "y") == @es(x, y)
    @test aes("x", "y") == aes(:x, :y)
    @test aes("x", y = "y") == aes(:x, y = :y)
    @test aes("x", y = "y") == @es(x, y = y)
    @test aes("x", y = "y") == @aes(x, y = y)
end

@testset "geom_point" begin
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

@testset "geom_bar" begin
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

@testset "geom_col" begin
    penguins_count = @chain penguins begin
        groupby(:species)
        @summarize(count = n())
        @arrange(species)
    end

    t = ggplot(penguins_count) + 
        geom_col(@aes(x = species, y = count))
    
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

@testset "geom_line" begin
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

@testset "geom_boxplot" begin
    t = ggplot(penguins) + 
        geom_boxplot(@aes(x = species, y = bill_length_mm))
    
    cat_array = CategoricalArrays.CategoricalArray(penguins.species)
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :BoxPlot, 
                        levelcode.(cat_array),
                        penguins.bill_length_mm)
                ]; xticks = (unique(levelcode.(cat_array)),
                             unique(cat_array))
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

@testset "geom_violin" begin
    t = ggplot(penguins) + 
        geom_violin(@aes(x = species, y = bill_length_mm))
    
    cat_array = CategoricalArrays.CategoricalArray(penguins.species)
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Violin, 
                        levelcode.(cat_array),
                        penguins.bill_length_mm)
                ]; xticks = (unique(levelcode.(cat_array)),
                             unique(cat_array))
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

@testset "geom_histogram" begin
    t = ggplot(penguins) + 
        geom_histogram(@aes(x = bill_length_mm))
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Hist, 
                        penguins.bill_length_mm)
                ]
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

@testset "geom_density" begin
    t = ggplot(penguins, @aes(x = body_mass_g)) +
        geom_density()
    
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Density, 
                        penguins.body_mass_g)
                ]
            )
        )
    )
    
    @test plot_images_equal(t, m)
end

@testset "geom_errorbar" begin
    categories = ["A", "B", "C", "D"];
    n = length(categories);

    mean_values = rand(n);  # Random mean values for demonstration
    errors = rand(n) / 2;   # Random error values for demonstration

    LowerBound = mean_values .- errors;
    UpperBound = mean_values .+ errors;

    df_errorbar = DataFrame(
        Category = categories,
        cat_numeric = CategoricalArray(categories),
        MeanValue = mean_values,
        LowerBound = LowerBound,
        UpperBound = UpperBound);

    t = ggplot(df_errorbar, @aes(x = Category, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) +
        geom_point() + # to show the mean value
        geom_errorbar(width = 0.2) # width of the horizontal line at the top and bottom of the error bar

    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter, 
                        levelcode.(df_errorbar.cat_numeric),
                        df_errorbar.MeanValue),
                    Makie.PlotSpec(
                        :Rangebars, 
                        levelcode.(df_errorbar.cat_numeric),
                        df_errorbar.LowerBound,
                        df_errorbar.UpperBound)
                ]; xticks = (1:4, categories)
            )
        )
    )

    @test plot_images_equal(t, m)

end
