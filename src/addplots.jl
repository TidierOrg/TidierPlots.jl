
function get_options(geom_list)
    options = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options)
    end
    return options
end

function Base.:+(x::GGPlot, y::Union{Geom, Vector{Geom}, Aesthetics, AxisOptions, Attributes}...)::GGPlot
    theme = [i for i in y if i isa Attributes]

    if length(theme) == 0
        theme = Makie.theme_ggplot2() # default is to look like a ggplot
    else
        theme = theme[end] # use only the last specified theme
    end

    result = GGPlot(
        vcat(x.geoms, # if there are geoms or lists of geoms, append them to the ggplot's geoms
            [i              for i in y if i isa Geom],
            [i              for i in y if i isa Vector{Geom}]...),
        merge(x.default_aes, # if there are aes specs, make them the ggplot's defaults
            [i.named        for i in y if i isa Aesthetics]...),
        x.data, # the default data is passed on to the final ggplot
        merge(x.axis_options, # get any axis options out of the geoms into one location
            [i.axis_options for i in y if i isa Geom]...,
            [get_options(i) for i in y if i isa Vector{Geom}]...,
            [i.opt          for i in y if i isa AxisOptions]...),
        theme,
        merge(x.column_transformations,
            [i.column_transformations for i in y if i isa AxisOptions]...),
        merge(x.legend_options,
            [i.legend_options for i in y if i isa AxisOptions]...)
    )

    return result
end
