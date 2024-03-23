
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
        vcat(x.geoms, # if there are geoms or lists of geoms, append them to the ggplot's geoms
            [i              for i in y if i isa Geom], 
            [i              for i in y if i isa Vector{Geom}]...), 
        merge(x.default_aes, # if there are aes specs, make them the ggplot's defaults
            [i.aes          for i in y if i isa Aesthetics]...),
        x.data, # the default data is passed on to the final ggplot
        merge(x.axis_options, # get any axis options out of the geoms into one location
            [i.axis_options for i in y if i isa Geom]...,
            [get_options(i) for i in y if i isa Vector{Geom}]...,
            [i.opt          for i in y if i isa AxisOptions]...),
        theme
    )

    return result
end