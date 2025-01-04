function as_GridLayout(plot::GGPlot)
    plot_list = Dict{Tuple,Vector{Makie.PlotSpec}}()
    facet_boxes = Dict()
    facet_labels = Dict()
    axis_options = Dict{Symbol,Any}()

    colorbar_kwargs = Dict()
    colorbar_lowlim = Inf
    colorbar_highlim = -Inf
    colorbar = false

    legend = DataFrame(
        labels=String[],
        colors=Any[],
        options=Any[],
        element=Any[],
        title=String[])

    ymin = Inf
    xmin = Inf
    xmax = -Inf
    ymax = -Inf

    for geom in plot.geoms
        verbose[] && println("Preparing geom: $(geom.args["geom_name"]).")
        # use the dataframe from the geom if present, else ggplot one
        plot_data = isnothing(geom.data) ?
                    plot.data :
                    geom.data

        # inherit any aes specified in ggplot, unless inherit_aes is false
        aes_dict = get(geom.args, "inherit_aes", true) ?
                   merge(plot.default_aes, geom.aes) :
                   geom.aes

        # apply function if required to edit the aes/args/data
        aes_dict, args_dict, required_aes, plot_data =
            geom.pre_function(aes_dict, geom.args, geom.required_aes, plot_data)

        verbose[] && println("Using data:")
        verbose[] && @glimpse(plot_data)

        verbose[] && println("Using aes input:")
        verbose[] && println(aes_dict)

        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_geom = merge(_ggplot_to_makie, geom.special_aes)

        verbose[] && println("Makie translations used:")
        verbose[] && println(ggplot_to_makie_geom)

        aes_dict_makie = Dict{Symbol,Union{Symbol,Pair}}()

        # the name of the aes is translated to the makie term if needed
        for (aes_symbol, column_name) in aes_dict
            gg_aes = Symbol(aes_symbol)
            aes = get(ggplot_to_makie_geom, gg_aes, gg_aes)
            push!(aes_dict_makie, aes => column_name)
        end

        verbose[] && println("Translated aes dict:")
        verbose[] && println(aes_dict)

        # build a new dataframe with column names equal to the required aesthetics
        # this dataframe will take data from plot_data according to the rules outlined in the aes object
        aes_df_list = DataFrame[]

        for (aes, rule) in aes_dict_makie
            # aes is a symbol, the target column name
            # rule is a pair, the source columns and function to apply
            push!(aes_df_list, select(plot_data, rule[1] => rule[2] => aes))
        end

        if !isnothing(plot.facet_options)
            push!(aes_df_list,
                DataFrame(facet=plot_data[!, plot.facet_options.wrap]))
        end

        aes_df = hcat(aes_df_list...)

        # if there are no grouping aesthetics and no manually specified group, everything is part of the same group. Otherwise, make a grouping column out of the grouping aesthetics if one doesn't already exist
        grouping_aes = intersect(
            geom.grouping_aes,
            Symbol.(names(aes_df))
        )

        if !("group" in names(aes_df))
            if length(grouping_aes) == 0
                aes_df.group .= 1
            else
                aes_df.group = string.([aes_df[!, col] for col in grouping_aes]...)
            end
        end

        verbose[] && println("Built aes df:")
        verbose[] && @glimpse(aes_df)

        args_dict_makie = Dict{Symbol,Any}()

        supported_kwargs = get(_accepted_options_by_type, geom.visual,
            nothing)

        for (arg, value) in args_dict
            if !(Symbol(arg) in _internal_geom_options)
                ex_type = get(_makie_expected_type, arg, Any)
                converted_value = try_convert(ex_type, value, arg, geom.args["geom_name"])
                makie_attr = get(ggplot_to_makie_geom, Symbol(arg), Symbol(arg))
                if isnothing(supported_kwargs) || Symbol(makie_attr) in supported_kwargs
                    args_dict_makie[Symbol(makie_attr)] = converted_value
                else
                    @warn "Dropping unsupported argument: $makie_attr"
                end
            end
        end

        # after all edits have been made, apply the post_function

        aes_dict, args_dict, required_aes, aes_df =
            geom.post_function(aes_dict,
                args_dict,
                required_aes,
                aes_df)

        # default palettes

        plot_palette = plot.palette

        for palette_aes in intersect([:strokecolor, :color], Symbol.(names(aes_df)))
            if !haskey(plot_palette, palette_aes)
                if eltype(aes_df[!, palette_aes]) <: Number
                    plot_palette[palette_aes] = _default_continuous_palette
                else
                    plot_palette[palette_aes] = _default_discrete_palette
                end
            end
        end

        # handle axis ticks when the input variable is a string

        for a in required_aes
            if eltype(aes_df[!, Symbol(a)]) <: AbstractString
                plot_palette[Symbol(a)] = CategoricalArray
                axis_options[Symbol(a * "ticks")] = (
                    1:maximum(levelcode.(CategoricalArray(aes_df[!, Symbol(a)]))),
                    string.(levels(CategoricalArray(aes_df[!, Symbol(a)])))
                )
            end
        end

        # convert all aes columns to the format expected by makie

        typed_aes_df = convert_aes_df_types(aes_df, plot_palette)

        verbose[] && println("Typed DataFrame:")
        verbose[] && @glimpse typed_aes_df

        # keep track of the global max and min on each axis
        if "x" in names(typed_aes_df) && eltype(typed_aes_df.x) <: Number
            xmin = min(xmin, minimum(typed_aes_df.x))
            xmax = max(xmax, maximum(typed_aes_df.x))
        end

        if "y" in names(typed_aes_df) && eltype(typed_aes_df.y) <: Number
            ymin = min(ymin, minimum(typed_aes_df.y))
            ymax = max(ymax, maximum(typed_aes_df.y))
        end

        # if there are no facet options just plot everything in 1,1
        # if there are, make a column that indicates which facet each point belongs to
        if isnothing(plot.facet_options)
            typed_aes_df.facet .= [(1, 1)] # everything goes in the same "facet"
        else
            facet_names = unique(typed_aes_df.facet)
            facet_positions, facet_labels, facet_boxes =
                position_facets(facet_names,
                    plot.facet_options.nrow,
                    plot.facet_options.ncol)
            typed_aes_df.facet = [facet_positions[k] for k in typed_aes_df.facet]
        end

        for (key, group_aes_df) in pairs(groupby(typed_aes_df, [:group, :facet]))
            required_aes_data = []

            for a in required_aes
                data = group_aes_df[!, Symbol(a)]
                if !(Symbol(a) in _verbatim_aes)
                    if eltype(data) <: CategoricalValue
                        labels = levels(data)
                        data = levelcode.(data)
                    end
                end
                push!(required_aes_data, data)
            end

            optional_aes_data = Dict()

            for a in names(group_aes_df)
                if String(a) in required_aes
                    continue
                end
                if !isnothing(supported_kwargs)
                    if !(Symbol(a) in supported_kwargs)
                        continue
                    end
                end

                data = group_aes_df[!, Symbol(a)]

                # for text and labels - strings for these are not categories
                if (Symbol(a) in _verbatim_aes)
                    data = string.(data)
                end

                # for geom_density and geom_line
                if Symbol(a) in grouping_aes
                    data = first(data)
                end

                push!(optional_aes_data, Symbol(a) => data)

                palette_function = get(plot.palette, :color, nothing)

                isnothing(palette_function) && continue

                labels = unique(plot_data[!, :color])

                plottable_data = palette_function.(
                    levelcode.(CategoricalArray(plot_data[!, :color]))
                )

                append!(legend,
                    sort(DataFrame(
                            labels=labels,
                            colors=unique(plottable_data),
                            options=_legend_geom_symbols[geom.args["geom_name"]],
                            element=_legend_geom_elements[geom.args["geom_name"]],
                            title=get(plot.legend_options[:color], :name, titlecase(string(:color)))
                        ),
                        :labels)
                )
            end

            args = Tuple([geom.visual, required_aes_data...])
            kwargs = merge(args_dict_makie, optional_aes_data)

            verbose[] && println("Makie call args:")
            verbose[] && println(args)

            verbose[] && println("Makie call kwargs:")
            verbose[] && println(kwargs)

            # push completed PlotSpec (type, args, and kwargs) to the list of plots in the appropriate facet
            facet_position = key[2]
            if haskey(plot_list, facet_position) # add to list if exists
                plot_list[facet_position] = vcat(
                    plot_list[facet_position],
                    Makie.PlotSpec(args...; kwargs...))
            else
                plot_list[facet_position] = [Makie.PlotSpec(args...; kwargs...)]
            end
        end
    end

    # rename and correct types on all axis options
    for (arg, value) in plot.axis_options
        if !(Symbol(arg) in _internal_geom_options)
            ex_type = get(_makie_expected_type, arg, Any)
            converted_value = try_convert(ex_type, value, arg, "ggplot")
            makie_attr = get(_ggplot_to_makie, arg, arg)
            axis_options[Symbol(makie_attr)] = converted_value
        end
    end

    if !haskey(axis_options, :limits) && !isnothing(plot.facet_options)
        expand_x = (xmax - xmin) * 0.05
        expand_y = (ymax - ymin) * 0.05

        if any(isinf.([xmax, xmin, ymax, ymin]))
            axis_options[:limits] = (nothing, nothing)
        elseif !plot.facet_options.free_x && plot.facet_options.free_y
            expandx = (xmax - xmin) * 0.05
            axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), nothing)
        elseif plot.facet_options.free_x && !plot.facet_options.free_y
            axis_options[:limits] = (nothing, (ymin - expand_y, ymax + expand_y))
        elseif !plot.facet_options.free_x && !plot.facet_options.free_y
            axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), (ymin - expand_y, ymax + expand_y))
        end
    end

    l = nothing

    if isnothing(l)
        return Makie.SpecApi.GridLayout(
            [k => Makie.SpecApi.Axis(plots=v; axis_options...) for
             (k, v) in plot_list]...,
            facet_labels...,
            facet_boxes...
        )
    else
        return [Makie.SpecApi.GridLayout(
            [k => Makie.SpecApi.Axis(plots=v; axis_options...) for
             (k, v) in plot_list]...,
            facet_labels...,
            facet_boxes...
        ) l]
    end
end


function draw_ggplot(plot::GGPlot)
    Makie.plot(as_GridLayout(plot))
end

function draw_ggplot(plot::GGPlot, size::Tuple)
    Makie.plot(
        Makie.SpecApi.GridLayout(
            as_GridLayout(plot)
        ), figure=(; size=size)
    )
end

function draw_ggplot(plot_grid::GGPlotGrid)
    Makie.plot(plot_grid.grid)
end

function draw_ggplot(plot_grid::GGPlotGrid, size::Tuple)
    Makie.plot(plot_grid.grid, figure=(; size=size))
end
