
function get_options(geom_list)
    options = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options)
    end
    return options
end

function Base.:+(x::GGPlot, y...)::GGPlot
    theme = [i for i in y if t isa Attributes]

    if length(theme) == 0
        theme = Makie.theme_ggplot2()
    else
        theme = theme[end]
    end
    
    result = GGPlot(
        vcat(x.geoms, 
            [i              for i in y if i isa Geom], 
            [i              for i in y if i isa Vector{Geom}]...), 
        merge(x.default_aes, 
            [i.aes          for i in y if i isa Aesthetics]...),
        x.data,
        merge(x.axis_options, 
            [i.axis_options for i in y if i isa Geom]...,
            [get_options(i) for i in y if i isa Vector{Geom}]...,
            [i.opt          for i in y if i isa AxisOptions]...),
        theme
    )

    return result
end