function get_options(geom_list)
    options = Dict()
    palette = Dict()
    legend = Dict()
    for geom in geom_list
        merge!(options, geom.axis_options.opt)
        merge!(palette, geom.axis_options.palette)
        merge!(legend, geom.axis_options.legend_options)
    end
    return AxisOptions(options, palette, legend)
end

function Base.:+(x::GGPlot, y::Union{Geom,Vector{Geom},Aesthetics,AxisOptions,FacetOptions,Attributes}...)::GGPlot

    themes = [i for i in y if i isa Attributes]
    theme = length(themes) == 0 ? Makie.theme_ggplot2() : themes[end]

    facet = [i for i in y if i isa FacetOptions]
    facet_options = length(facet) == 0 ? nothing : facet[end]

    opt = x.axis_options.opt
    palette = x.axis_options.palette
    legend_options = x.axis_options.legend_options

    for item in [i for i in y if typeof(i) <:
        Union{Geom,Vector{Geom},AxisOptions}]

        if item isa Vector{Geom}
            item = get_options(item)
        end

        o = item isa AxisOptions ? item.opt :
            item.axis_options.opt
        p = item isa AxisOptions ? item.palette :
            item.axis_options.palette
        l = item isa AxisOptions ? item.legend_options :
            item.axis_options.legend_options

        opt = merge(opt, o)

        for (scale, options) in p
            if haskey(palette, scale)
                palette[scale] = merge(palette[scale], options)
            else
                palette[scale] = options
            end
        end

        for (scale, options) in l
            if haskey(legend_options, scale)
                legend_options[scale] = merge(legend_options[scale], options)
            else
                legend_options[scale] = options
            end
        end
    end

    combined_axis_options = AxisOptions(
        opt,
        palette,
        legend_options
    )

    result = GGPlot(
        vcat(x.geoms, # if there are geoms or lists of geoms, append them to the ggplot's geoms
            [i for i in y if i isa Geom],
            [i for i in y if i isa Vector{Geom}]...),
        merge(x.default_aes, # if there are aes specs, make them the ggplot's defaults
            [i.named for i in y if i isa Aesthetics]...),
        x.data, # the default data is passed on to the final ggplot
        combined_axis_options,
        theme,
        facet_options
    )

    return result
end
