
function get_options(geom_list)
    options = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options)
    end
    return options
end

function Base.:+(x::GGPlot, y::Union{Geom, Vector{Geom}, Aesthetics, AxisOptions, FacetOptions, Attributes}...)::GGPlot

    themes = [i for i in y if i isa Attributes]
    theme = length(themes) == 0 ? Makie.theme_ggplot2() : themes[end]

    facet = [i for i in y if i isa FacetOptions]
    facet_options = length(facet) == 0 ? nothing : facet[end]

    color = [i.color_palette for i in y if i isa AxisOptions]
    color_palette = length(color) == 0 ? nothing : color[end]

    fill = [i.fill_palette for i in y if i isa AxisOptions]
    fill_palette = length(fill) == 0 ? nothing : color[fill]

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
        merge(x.legend_options,
            [i.legend_options for i in y if i isa AxisOptions]...),
        facet_options,
        color_palette,
        fill_palette
    )

    return result
end
