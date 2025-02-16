"""
Sets which scales will get legends or colorbars. Use the name of the scale and either the string "legend" or "colorbar" to add a guide.
"""
function guides(args...; kwargs...)
    return AxisOptions(
        Dict{Symbol,Any}(),
        Dict(),
        Dict(k => Dict(:guide => Symbol(v)) for (k, v) in Dict(kwargs))
    )
end

function update_legend(legend,
    plot_axis_options,
    geom_name,
    a,
    labels_aes_df,
    colorbar_highlim,
    colorbar_lowlim,
    colorbar_kwargs,
    colorbar)

    palette_function = get(plot_axis_options.palette, Symbol(a), nothing)

    isnothing(palette_function) && return (colorbar_highlim, colorbar_lowlim, colorbar_kwargs, colorbar, legend)
    !haskey(_legend_geom_symbols,
        geom_name) && return (colorbar_highlim, colorbar_lowlim, colorbar_kwargs, colorbar, legend)
    !haskey(_legend_geom_elements,
        geom_name) && return (colorbar_highlim, colorbar_lowlim, colorbar_kwargs, colorbar, legend)

    labels_for_this_aes = subset(labels_aes_df,
        :col_name => ByRow(x -> x == a))

    if haskey(plot_axis_options.legend_options, Symbol(a))
        l_type = get(plot_axis_options.legend_options[Symbol(a)], :type, "na")
        legend_title = get(plot_axis_options.legend_options[Symbol(a)], :name, a)
        draw_colorbar = get(plot_axis_options.legend_options[Symbol(a)], :guide, :auto)
        if draw_colorbar == :auto
            if l_type in ["continuous", "binned"]
                draw_colorbar = :colorbar
            elseif l_type in ["discrete", "manual"]
                draw_colorbar = :legend
            end
        end
    else
        draw_colorbar = :none
        legend_title = a
    end

    if draw_colorbar == :colorbar
        colorbar_kwargs[:colormap] =
            plot_axis_options.legend_options[Symbol(a)][:type] == "continuous" ? Symbol(plot_axis_options.legend_options[Symbol(a)][:palette]) :
            cgrad(Symbol(plot_axis_options.legend_options[Symbol(a)][:palette]), 5, categorical=true)

        colorbar_lowlim = min(
            minimum(labels_for_this_aes.original_value), colorbar_lowlim)

        colorbar_highlim = max(
            maximum(labels_for_this_aes.original_value), colorbar_highlim)

        colorbar = true
    elseif draw_colorbar == :legend
        if Symbol(a) == :markersize
            o = labels_for_this_aes.original_value
            n = labels_for_this_aes.new_value

            ro = quantile(o, [0, 0.25, 0.5, 0.75, 1])
            rn = quantile(n, [0, 0.25, 0.5, 0.75, 1])

            append!(legend,
                sort(DataFrame(
                        labels=ro,
                        colors=RGB(0, 0, 0),
                        options=[Dict(:marker => :circle, :markersize => n) for n in rn],
                        element=MarkerElement,
                        title=legend_title
                    ),
                    :labels), promote=true
            )
        elseif Symbol(a) == :linewidth
            o = labels_for_this_aes.original_value
            n = labels_for_this_aes.new_value

            ro = quantile(o, [0, 0.25, 0.5, 0.75, 1])
            rn = quantile(n, [0, 0.25, 0.5, 0.75, 1])

            append!(legend,
                sort(DataFrame(
                        labels=ro,
                        colors=RGB(0, 0, 0),
                        options=[Dict(:linewidth => n) for n in rn],
                        element=LineElement,
                        title=legend_title
                    ),
                    :labels), promote=true
            )
        elseif Symbol(a) == :marker
            append!(legend,
                sort(DataFrame(
                        labels=labels_for_this_aes.original_value,
                        colors=RGB(0, 0, 0),
                        options=[Dict(:marker => n, :markersize => 12) for n in labels_for_this_aes.new_value],
                        element=MarkerElement,
                        title=legend_title
                    ),
                    :labels), promote=true
            )
        else
            append!(legend,
                sort(DataFrame(
                        labels=labels_for_this_aes.original_value,
                        colors=labels_for_this_aes.new_value,
                        options=get(
                            _legend_geom_symbols,
                            geom_name,
                            Dict(:marker => :circle, :markersize => 12)
                        ),
                        element=get(
                            _legend_geom_elements,
                            geom_name,
                            MarkerElement
                        ),
                        title=legend_title
                    ),
                    :labels), promote=true
            )
        end
    end

    return (
        colorbar_highlim, colorbar_lowlim, colorbar_kwargs, colorbar, legend
    )
end
