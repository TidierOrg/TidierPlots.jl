
function Base.:+(x::GGPlot, y...)::GGPlot
    theme = [t for t in y if t isa Attributes]

    if length(theme) == 0
        theme = Makie.theme_ggplot2()
    else
        theme = theme[end]
    end
    
    result = GGPlot(
        vcat(x.geoms, [i for i in y if i isa Geom]), 
        merge(x.default_aes, 
            [a.aes for a in y if a isa Aesthetics]...),
        x.data,
        merge(x.axis_options, 
            [l.axis_options for l in y if l isa Geom]...,
            [d for d in y if d isa Dict]...),
        theme
    )

    return result
end