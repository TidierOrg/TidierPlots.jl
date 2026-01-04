function ggsave(path::String, plot::Union{GGPlot,GGPlotGrid};
    scale=2, height=nothing, width=nothing)

    if xor(isnothing(height), isnothing(width))
        throw(ArgumentError("Specify either: both height and width OR neither height nor width."))
    end

    # does not support different themes per plot in a grid
    theme = plot isa GGPlotGrid ? plot.plots[1].theme : plot.theme

    if !isnothing(height)
        save(path,
            with_theme(theme) do
                draw_ggplot(plot, (width, height))
            end; px_per_unit=scale)
    else
        save(path,
            with_theme(theme) do
                draw_ggplot(plot)
            end; px_per_unit=scale)
    end
end

function ggsave(plot::Union{GGPlot,GGPlotGrid}, path::String; scale=2, height=nothing, width=nothing)
    ggsave(path, plot; scale=scale, height=height, width=width)
end

@testitem "ggsave" begin
    using DataFrames

    plot = ggplot()
    path = tempname() * ".png"
    @test_throws ArgumentError ggsave(plot, path; height = 100)
    @test_throws ArgumentError ggsave(plot, path; width = 100)

    @test_nowarn ggsave(plot, path)
    @test_nowarn ggsave(path, plot)
    @test_nowarn ggsave(plot, path; height = 100, width = 100)

    g1 = ggplot(DataFrame(x = [1,3], y = [1,3])) +
        geom_point(aes(x = :x, y = :y))
    g2 = ggplot(DataFrame(x = [1,2], y = [1,2])) +
        geom_point(aes(x = :x, y = :y))

    gg = g1 + g2

    @test_nowarn draw_ggplot(gg, (300, 300))
end