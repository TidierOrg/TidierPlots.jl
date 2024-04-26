using Pkg
Pkg.activate("..")
using TidierPlots
GGPlot = TidierPlots.GGPlot
GGPlotGrid = TidierPlots.GGPlotGrid

Pkg.activate(".")
using Test
using Makie
SpecApi = Makie.SpecApi
using Parquet2
using DataFrames
using Images

include("difference_hash.jl")
include("../src/patchwork.jl")

penguins = DataFrame(Parquet2.readfile(joinpath(@__DIR__, "penguins.parq")))

@testset "horizontal concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m2 = Makie.plot(
        Makie.SpecApi.GridLayout(hcat([test_ax for _ in 1:2]...))
    )
    m3 = Makie.plot(
        Makie.SpecApi.GridLayout(hcat([test_ax for _ in 1:3]...))
    )

    @test plot_images_equal(t | t, m2)
    @test plot_images_equal(t + t, m2)
    @test plot_images_equal(|(t, t, t), m3)
    @test plot_images_equal(t + t + t, m3)
end

@testset "vertical concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m2 = Makie.plot(
        Makie.SpecApi.GridLayout(vcat([test_ax for _ in 1:2]...))
    )
    m3 = Makie.plot(
        Makie.SpecApi.GridLayout(vcat([test_ax for _ in 1:3]...))
    )

    @test plot_images_equal(t / t, m2)
    @test plot_images_equal(/(t, t, t), m3)
end

@testset "grid concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m21 = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.GridLayout([test_ax test_ax]),
            Makie.SpecApi.GridLayout([test_ax])
        )
    )

    @test plot_images_equal((t | t) / t, m21)
end
