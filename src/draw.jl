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

    legend_title = " "

    # Track legend options across all geoms for final rendering
    final_legend_options = copy(plot.axis_options.legend_options)

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

        # makie does not show strokes by default
        if haskey(aes_dict_makie, :strokecolor) &&
           !haskey(args_dict, "strokewidth")
            args_dict["strokewidth"] = 1
        end

        verbose[] && println("Translated aes dict:")
        verbose[] && println(aes_dict_makie)

        # build a new dataframe with column names equal to the required aesthetics
        # this dataframe will take data from plot_data according to the rules outlined in the aes object
        aes_df_list = DataFrame[]

        for (aes, rule) in aes_dict_makie
            # aes is a symbol, the target column name
            # rule is a pair, the source columns and function to apply
            push!(aes_df_list, select(plot_data, rule[1] => rule[2] => aes))
        end

        if !isnothing(plot.facet_options)
            if !isnothing(plot.facet_options.wrap)
                # facet_wrap
                push!(aes_df_list,
                    DataFrame(facet=plot_data[!, plot.facet_options.wrap]))
            else
                # facet_grid
                rows = isnothing(plot.facet_options.rows) ?
                       repeat([nothing], nrow(plot_data)) :
                       plot_data[!, plot.facet_options.rows]
                cols = isnothing(plot.facet_options.cols) ?
                       repeat([nothing], nrow(plot_data)) :
                       plot_data[!, plot.facet_options.cols]
                push!(aes_df_list,
                    DataFrame(facet=[(r, c) for (r, c) in zip(rows, cols)]))
            end
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

        supported_kwargs = accepted_options_by_type(geom.visual)

        for (arg, value) in args_dict
            if !(Symbol(arg) in _internal_geom_options)
                ex_type = get(_makie_expected_type, arg, Any)
                converted_value = try_convert(ex_type, value, arg, geom.args["geom_name"])
                makie_attr = get(ggplot_to_makie_geom, Symbol(arg), Symbol(arg))
                if isnothing(supported_kwargs) || Symbol(makie_attr) in supported_kwargs
                    args_dict_makie[Symbol(makie_attr)] = converted_value
                else
                    throw(ArgumentError("Unsupported argument: $makie_attr"))
                end
            end
        end

        # after all edits have been made, apply the post_function

        aes_dict, args_dict_makie, required_aes, aes_df =
            geom.post_function(aes_dict,
                args_dict_makie,
                required_aes,
                aes_df)

        # default palettes

        plot_palette = copy(plot.axis_options.palette)
        plot_legend_options = copy(plot.axis_options.legend_options)

        for palette_aes in intersect([:strokecolor, :color], Symbol.(names(aes_df)))
            if !haskey(plot_palette, palette_aes)
                if eltype(aes_df[!, palette_aes]) <: Number
                    plot_palette[palette_aes] = _default_continuous_palette
                else
                    plot_palette[palette_aes] = _default_discrete_palette
                end
            end
            # Set up default legend_options if not already specified
            if !haskey(plot_legend_options, palette_aes)
                # Get the original column name from aes_dict for the legend title
                aes_key = palette_aes == :color ?
                    (haskey(aes_dict, :color) ? :color : (haskey(aes_dict, :colour) ? :colour : nothing)) :
                    (haskey(aes_dict, palette_aes) ? palette_aes : nothing)
                col_name = if !isnothing(aes_key) && haskey(aes_dict, aes_key)
                    string(first(aes_dict[aes_key]))  # Get column name from the Pair
                else
                    string(palette_aes)
                end

                if eltype(aes_df[!, palette_aes]) <: Number
                    plot_legend_options[palette_aes] = Dict(
                        :type => "continuous",
                        :guide => :colorbar,
                        :name => col_name,
                        :palette => :viridis
                    )
                else
                    plot_legend_options[palette_aes] = Dict(
                        :type => "discrete",
                        :guide => :legend,
                        :name => col_name
                    )
                end
            elseif !haskey(plot_legend_options[palette_aes], :name)
                # legend_options exists but no name - add the column name
                aes_key = palette_aes == :color ?
                    (haskey(aes_dict, :color) ? :color : (haskey(aes_dict, :colour) ? :colour : nothing)) :
                    (haskey(aes_dict, palette_aes) ? palette_aes : nothing)
                if !isnothing(aes_key) && haskey(aes_dict, aes_key)
                    plot_legend_options[palette_aes][:name] = string(first(aes_dict[aes_key]))
                end
            end
        end

        # Create local axis options with updated palette and legend_options
        plot_axis_options = AxisOptions(
            plot.axis_options.opt,
            plot_palette,
            plot_legend_options
        )

        # handle axis ticks when the input variable is a string

        for a in required_aes
            if eltype(aes_df[!, Symbol(a)]) <: AbstractString
                plot_palette[Symbol(a)] = CategoricalArray

                axis_options[Symbol(a * "ticks")] = (
                    unique(levelcode.(CategoricalArray(aes_df[!, Symbol(a)]))),
                    unique(aes_df[!, Symbol(a)])
                )
            elseif eltype(aes_df[!, Symbol(a)]) <: CategoricalValue
                axis_options[Symbol(a * "ticks")] = (
                    unique(levelcode.(aes_df[!, Symbol(a)])),
                    unique(string.(aes_df[!, Symbol(a)])))
            end
        end

        # convert all aes columns to the format expected by makie

        # if there is no alpha column, set everything to 1.0

        if !("alpha" in names(aes_df)) && :color in supported_kwargs
            aes_df.alpha .= 1.0
        end

        # if there is no color column, set everything to black

        if !("color" in names(aes_df)) && :color in supported_kwargs
            if !haskey(args_dict_makie, :color)
                aes_df.color .= RGB(0, 0, 0)
            else
                aes_df.color .= args_dict_makie[:color]
                plot_palette[:color] = identity
            end
        end

        typed_aes_df = convert_aes_df_types(aes_df, plot_palette)
        labels_aes_df = get_unique_labels(aes_df, plot_palette)

        # alpha values need to be tupled with color

        if :color in supported_kwargs
            typed_aes_df.color .= [(c, a) for (c, a) in zip(
                typed_aes_df.color, typed_aes_df.alpha
            )]
            select!(typed_aes_df, Not(:alpha))
        end

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
                    plot.facet_options.ncol,
                    plot.facet_options.labels)
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

                if Symbol(a) in _internal_geom_options
                    continue
                end

                data = group_aes_df[!, Symbol(a)]

                # for text and labels - strings for these are not categories
                if (Symbol(a) in _verbatim_aes)
                    data = string.(data)
                end

                # for geom_density and geom_line
                if length(unique(group_aes_df[!, Symbol(a)])) == 1
                    data = first(data)
                end

                push!(optional_aes_data, Symbol(a) => data)

                colorbar_highlim,
                colorbar_lowlim,
                colorbar_kwargs,
                colorbar,
                legend = update_legend(
                    legend,
                    plot_axis_options,
                    geom.args["geom_name"],
                    a,
                    labels_aes_df,
                    colorbar_highlim,
                    colorbar_lowlim,
                    colorbar_kwargs,
                    colorbar
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

        # Merge this geom's legend options into final_legend_options
        merge!(final_legend_options, plot_legend_options)
    end

    # rename and correct types on all axis options
    for (arg, value) in plot.axis_options.opt
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

    verbose[] && println("Legend dataframe:")
    verbose[] && println(unique(legend))

    # if we don't need a legend or colorbar
    if nrow(legend) == 0 && !colorbar
        return Makie.SpecApi.GridLayout(
            [k => Makie.SpecApi.Axis(plots=v; axis_options...) for
             (k, v) in plot_list]...,
            facet_labels...,
            facet_boxes...
        )
    end

    if nrow(legend) != 0

        labels_list = []
        elems_list = []
        titles_list = []

        for t in unique(legend.title)

            labels = String[]
            elems = Any[]

            sublegend = subset(
                subset(legend, :title => ByRow(x -> x == t)),
                :labels => ByRow(x -> x != "__tidierplots_default__")
            )

            title = first(sublegend.title)

            for l in eachrow(sublegend)
                push!(elems, l.element(color=l.colors; l.options...))
                push!(labels, string(l.labels))
            end

            push!(labels_list, labels)
            push!(elems_list, elems)
            push!(titles_list, title)

        end

        l = (1, 2) => Makie.SpecApi.GridLayout(
            Makie.SpecApi.Legend([e for e in elems_list],
                [l for l in labels_list],
                [t for t in titles_list]))
    else
        title = haskey(final_legend_options, :color) ?
            get(final_legend_options[:color], :name, " ") : " "
        l = (1, 2) => Makie.SpecApi.GridLayout(
            Makie.SpecApi.Colorbar(; colorbar_kwargs...,
                limits=(colorbar_lowlim, colorbar_highlim), label=title))
    end

    return Makie.SpecApi.GridLayout(
        (1, 1) => Makie.SpecApi.GridLayout(
            [k => Makie.SpecApi.Axis(plots=v; axis_options...) for
             (k, v) in plot_list]...,
            facet_labels...,
            facet_boxes...
        ),
        l)
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
