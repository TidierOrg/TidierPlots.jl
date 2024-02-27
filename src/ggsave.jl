function ggsave(path::String, plot::GGPlot; scale = 2)
    save(path, 
    with_theme(plot.theme) do
        draw_ggplot(plot)
    end;
    px_per_unit = scale)
end

function ggsave(plot::GGPlot, path::String; scale = 2)
    save(path, 
        with_theme(plot.theme) do
            draw_ggplot(plot)
        end;
        px_per_unit = scale)
end