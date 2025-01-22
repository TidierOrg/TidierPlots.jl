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
