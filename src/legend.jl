function build_legend(plot::GGPlot)
    elem_1 = [MarkerElement(color = :blue, marker = :circle, markersize = 15)]
    elem_2 = [MarkerElement(color = :orange, marker = :circle, markersize = 15)]
    elem_3 = [MarkerElement(color = :green, marker = :circle, markersize = 15)]

    return Makie.SpecApi.Legend([elem_1, elem_2, elem_3], ["This is", "a fake", "legend"])
end