
function get_options(geom_list)
    options = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options)
    end
    return options
end

function Base.:+(x::GGPlot, y::Union{Geom,Vector{Geom},Aesthetics,AxisOptions,FacetOptions,Attributes}...)::GGPlot

    themes = [i for i in y if i isa Attributes]
    theme = length(themes) == 0 ? Makie.theme_ggplot2() : themes[end]

    facet = [i for i in y if i isa FacetOptions]
    facet_options = length(facet) == 0 ? nothing : facet[end]

    legend_options = x.legend_options
    for legend in [i.legend_options for i in y if i isa AxisOptions]
        for (scale, options) in legend
            if haskey(legend_options, scale)
                merge!(legend_options[scale], options)
            else
                legend_options[scale] = options
            end
        end
    end

    result = GGPlot(
        vcat(x.geoms, # if there are geoms or lists of geoms, append them to the ggplot's geoms
            [i for i in y if i isa Geom],
            [i for i in y if i isa Vector{Geom}]...),
        merge(x.default_aes, # if there are aes specs, make them the ggplot's defaults
            [i.named for i in y if i isa Aesthetics]...),
        x.data, # the default data is passed on to the final ggplot
        merge(x.axis_options, # get any axis options out of the geoms into one location
            [i.axis_options for i in y if i isa Geom]...,
            [get_options(i) for i in y if i isa Vector{Geom}]...,
            [i.opt for i in y if i isa AxisOptions]...),
        theme,
        legend_options,
        facet_options,
        merge(x.palette,
            [i.palette for i in y if i isa AxisOptions]...)
    )

    return result
end
