
function get_options(geom_list)
    options = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options)
    end
    return options
end

function Base.:+(x::GGPlot, y...)::GGPlot
    theme = [t for t in y if t isa Attributes]

    if length(theme) == 0
        theme = Makie.theme_ggplot2()
    else
        theme = theme[end]
    end
    
    result = GGPlot(
        vcat(x.geoms, 
            [i for i in y if i isa Geom], 
            [j for j in y if j isa Vector{Geom}]...), 
        merge(x.default_aes, 
            [a.aes for a in y if a isa Aesthetics]...),
        x.data,
        merge(x.axis_options, 
            [l.axis_options for l in y if l isa Geom]...,
            [get_options(m) for m in y if m isa Vector{Geom}]...,
            [d.opt for d in y if d isa AxisOptions]...),
        theme
    )

    return result
end