# COV_EXCL_START

for theme_name in (:theme_black, :theme_dark, :theme_ggplot2, :theme_light, :theme_minimal)
    @eval begin
        function Makie.$theme_name(plot::GGPlot)
            return plot + $theme_name()
        end
    end
end

# COV_EXCL_STOP

function theme(args...; kwargs...)
    return AxisOptions(Dict(kwargs), Dict(), Dict())
end

@testitem "themes" begin
    invis = TidierPlots.theme(background = :transparent)
    @test invis.opt[:background] == :transparent
end
