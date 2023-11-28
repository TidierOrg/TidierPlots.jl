for theme_name in (:theme_black, :theme_dark, :theme_ggplot2, :theme_light, :theme_minimal)
    @eval begin 
        function Makie.$theme_name(plot::GGPlot)
            return plot + $theme_name()
        end
    end
end