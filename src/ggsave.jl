function ggsave(path::String, plot::GGPlot; scale = 0.75)
    save(path, draw_ggplot(plot); px_per_unit = scale)
end

function ggsave(plot::GGPlot, path::String; scale = 0.75)
    save(path, draw_ggplot(plot); px_per_unit = scale)
end