function ggsave(path::String, plot::GGPlot; scale = 0.75)
    save(path, 
    with_theme(plot.theme) do
        draw_ggplot(plot)
    end;
    px_per_unit = scale)
end

function ggsave(plot::GGPlot, path::String; scale = 0.75)
    save(path, 
        with_theme(plot.theme) do
            draw_ggplot(plot)
        end;
        px_per_unit = scale)
end