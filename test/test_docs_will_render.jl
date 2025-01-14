# this only works locally
# uncomment the include statement in runtests to check
# if the examples in the docs will run without errors

@testset "docs-render" begin
    @testset "geom_bar" begin
        include("../docs/examples/geoms/geom_bar.jl")
        @test true
    end
    @testset "geom_boxplot" begin
        include("../docs/examples/geoms/geom_boxplot.jl")
        @test true
    end
    @testset "geom_density" begin
        include("../docs/examples/geoms/geom_density.jl")
        @test true
    end
    @testset "geom_errorbar" begin
        include("../docs/examples/geoms/geom_errorbars.jl")
        @test true
    end
    @testset "geom_hist" begin
        include("../docs/examples/geoms/geom_hist.jl")
        @test true
    end
    @testset "geom_hvlines" begin
        include("../docs/examples/geoms/geom_hvlines.jl")
        @test true
    end
    @testset "geom_lines" begin
        include("../docs/examples/geoms/geom_lines.jl")
        @test true
    end
    @testset "geom_point" begin
        include("../docs/examples/geoms/geom_point.jl")
        @test true
    end
    @testset "geom_smooth" begin
        include("../docs/examples/geoms/geom_smooth.jl")
        @test true
    end
    @testset "geom_text" begin
        include("../docs/examples/geoms/geom_text.jl")
        @test true
    end
    @testset "geom_tile" begin
        include("../docs/examples/geoms/geom_violin.jl")
        @test true
    end
    @testset "geom_violin" begin
        include("../docs/examples/geoms/geom_violin.jl")
        @test true
    end
end
