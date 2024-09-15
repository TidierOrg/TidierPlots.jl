import Makie.SpecApi

function Makie.SpecApi.Axis(plot::GGPlot)
    plot_list = Makie.PlotSpec[]
    plot_list_by_facet = nothing
    facet_names = nothing
    facet_positions = nothing
    facet_boxes = Dict()
    facet_labels = Dict()
    axis_options = Dict{Symbol,Any}()

    ymin = Inf
    xmin = Inf
    xmax = -Inf
    ymax = -Inf

    for geom in plot.geoms
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
            geom.aes_function(aes_dict, geom.args, geom.required_aes, plot_data)

        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_geom = merge(_ggplot_to_makie, geom.special_aes)

        aes_dict_makie = Dict{Symbol,Union{Symbol,Pair}}()

        # the name of the aes is translated to the makie term if needed
        for (aes_symbol, column_name) in aes_dict
            aes = get(ggplot_to_makie_geom, aes_symbol, aes_symbol)
            push!(aes_dict_makie, Symbol(aes) => column_name)
        end

        # build a new dataframe with column names equal to the required aesthetics
        # this dataframe will take data from plot_data according to the rules outlined in the aes object
        aes_df_list = DataFrame[]

        for (aes, rule) in aes_dict_makie
            # aes is a symbol, the target column name
            # rule is a pair, the source columns and function to apply
            push!(aes_df_list, select(plot_data, rule[1] => rule[2] => aes))
        end

        aes_df = hcat(aes_df_list...)

        args_dict_makie = Dict{Symbol,Any}()

        supported_kwargs = get(_accepted_options_by_type, geom.visual, nothing)

        for (arg, value) in args_dict
            if !(Symbol(arg) in _internal_geom_options)
                ex_type = get(_makie_expected_type, arg, Any)
                converted_value = try_convert(ex_type, value, arg, geom.args["geom_name"])
                makie_attr = get(ggplot_to_makie_geom, arg, arg)
                if isnothing(supported_kwargs) || Symbol(makie_attr) in supported_kwargs
                    args_dict_makie[Symbol(makie_attr)] = converted_value
                else
                    @warn "Dropping unsupported argument: $makie_attr"
                end
            end
        end

        # keep track of the global max and min on each axis
        if "x" in names(aes_df)
            xmin = min(xmin, minimum(aes_df.x))
            xmax = max(xmax, maximum(aes_df.x))
        end

        if "y" in names(aes_df)
            ymin = min(ymin, minimum(aes_df.y))
            ymax = max(ymax, maximum(aes_df.y))
        end

        if length(intersect(
            names(aes_df), geom.grouping_aes)) == 0 &&
           isnothing(plot.facet_options)
            # if there are no grouping_aes given and no facets required, we only need one PlotSpec
            required_aes_data = [aes_df[!, a] for a in Symbol.(required_aes)]
            optional_aes_data = [
                Symbol(a) => aes_df[!, Symbol(a)]
                for a in names(aes_df)
                if (!(String(a) in required_aes) &&
                 (
                    isnothing(supported_kwargs) ||
                    a in supported_kwargs)
                )
            ]

            args = Tuple([geom.visual, required_aes_data...])
            kwargs = merge(args_dict_makie, Dict(optional_aes_data))

            # push completed PlotSpec (type, args, and kwargs) to the list of plots
            push!(plot_list, Makie.PlotSpec(args...; kwargs...))
        elseif length(intersect(keys(given_aes), geom.grouping_aes)) != 0 && isnothing(plot.facet_options)
            # if there is a aes in the grouping_aes list given, we will need multiple PlotSpecs
            # make a list of modified given_aes objects which only include the points from their subsets
            grouping_columns = [aes_dict_makie[a] for a in [intersect(keys(given_aes), geom.grouping_aes)...]]
            subgroup_given_aes = subgroup_split(given_aes, plot_data[!, grouping_columns])

            # push each one to the overall plot_list
            for sub in subgroup_given_aes
                required_aes_data = [p.makie_function(p.raw) for p in [sub[a] for a in Symbol.(required_aes)]]
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if (!(String(a) in required_aes) && (isnothing(supported_kwargs) || a in supported_kwargs))]

                args = Tuple([geom.visual, required_aes_data...])
                kwargs = merge(args_dict_makie, Dict(optional_aes_data))

                # if we are grouping, we only need a single value rather than a vector
                for aes in [intersect(keys(given_aes), geom.grouping_aes)...]
                    kwargs[aes] = first(kwargs[aes])
                end

                # push completed PlotSpec (type, args, and kwargs) to the list of plots
                push!(plot_list, Makie.PlotSpec(args...; kwargs...))
            end
        elseif length(intersect(keys(given_aes), geom.grouping_aes)) == 0
            # if there are facets but no grouping
            facetting_column = [plot.facet_options.wrap]
            subgroup_given_aes = subgroup_split(given_aes, plot_data[!, facetting_column])
            facet_names = unique(plot_data[!, plot.facet_options.wrap])
            facet_positions, facet_labels, facet_boxes = position_facets(facet_names, plot.facet_options.nrow, plot.facet_options.ncol)

            plot_list_by_facet = Dict(facet => Makie.PlotSpec[] for facet in facet_names)

            for (index, sub) in enumerate(subgroup_given_aes)
                required_aes_data = [p.makie_function(p.raw) for p in [sub[a] for a in Symbol.(required_aes)]]
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if (!(String(a) in required_aes) && (isnothing(supported_kwargs) || a in supported_kwargs))]

                args = Tuple([geom.visual, required_aes_data...])
                kwargs = merge(args_dict_makie, Dict(optional_aes_data))

                # push completed PlotSpec (type, args, and kwargs) to the list of plots
                push!(plot_list_by_facet[facet_names[index]], Makie.PlotSpec(args...; kwargs...))
            end
        else
            # if there are both facets and grouping required
            facetting_column = [plot.facet_options.wrap]
            grouping_columns = [aes_dict_makie[a] for a in [intersect(keys(given_aes), geom.grouping_aes)...]]
            subgroup_given_aes = subgroup_split(given_aes, plot_data[!, unique([facetting_column...; grouping_columns...])])
            facet_names = [n[plot.facet_options.wrap] for n in keys(groupby(plot_data, unique([facetting_column...; grouping_columns...])))]
            facet_positions, facet_labels, facet_boxes = position_facets(facet_names, plot.facet_options.nrow, plot.facet_options.ncol)

            plot_list_by_facet = Dict(facet => Makie.PlotSpec[] for facet in unique(facet_names))

            for (sub, facet_name) in zip(subgroup_given_aes, facet_names)
                required_aes_data = [p.makie_function(p.raw) for p in [sub[a] for a in Symbol.(required_aes)]]
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if (!(String(a) in required_aes) && (isnothing(supported_kwargs) || a in supported_kwargs))]

                args = Tuple([geom.visual, required_aes_data...])
                kwargs = merge(args_dict_makie, Dict(optional_aes_data))

                # since we are grouping, we only need a single value rather than a vector
                for aes in [intersect(keys(given_aes), geom.grouping_aes)...]
                    kwargs[aes] = first(kwargs[aes])
                end

                # push completed PlotSpec (type, args, and kwargs) to the list of plots
                push!(plot_list_by_facet[facet_name], Makie.PlotSpec(args...; kwargs...))
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

    if isnothing(plot.facet_options)
        return length(axis_options) == 0 ?
               Makie.SpecApi.Axis(plots=plot_list) :
               Makie.SpecApi.Axis(plots=plot_list; axis_options...)
    else
        if !haskey(axis_options, :limits)
            expand_x = (xmax - xmin) * 0.05
            expand_y = (ymax - ymin) * 0.05

            if !plot.facet_options.free_x && plot.facet_options.free_y
                expandx = (xmax - xmin) * 0.05
                axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), nothing)
            elseif plot.facet_options.free_x && !plot.facet_options.free_y
                axis_options[:limits] = (nothing, (ymin - expand_y, ymax + expand_y))
            elseif !plot.facet_options.free_x && !plot.facet_options.free_y
                axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), (ymin - expand_y, ymax + expand_y))
            end
        end

        if length(axis_options) == 0
            return Makie.SpecApi.GridLayout(
                [facet_positions[name] => Makie.SpecApi.Axis(plots=plot_list_by_facet[name]) for name in facet_names]...,
                facet_labels...,
                facet_boxes...
            )
        else
            return Makie.SpecApi.GridLayout(
                [facet_positions[name] => Makie.SpecApi.Axis(plots=plot_list_by_facet[name]; axis_options...) for name in facet_names]...,
                facet_labels...,
                facet_boxes...
            )
        end
    end
end

function draw_ggplot(plot::GGPlot)
    axis = Makie.SpecApi.Axis(plot)
    legend = build_legend(plot)

    if isnothing(legend)
        Makie.plot(
            Makie.SpecApi.GridLayout(
                axis
            )
        )
    else
        Makie.plot(
            Makie.SpecApi.GridLayout(
                [axis legend]
            )
        )
    end
end

function draw_ggplot(plot::GGPlot, size::Tuple)
    axis = Makie.SpecApi.Axis(plot)
    legend = build_legend(plot)

    if isnothing(legend)
        Makie.plot(
            Makie.SpecApi.GridLayout(
                axis
            ), figure=(; size=size)
        )
    else
        Makie.plot(
            Makie.SpecApi.GridLayout(
                [axis legend]
            ), figure=(; size=size)
        )
    end
end

function draw_ggplot(plot_grid::GGPlotGrid)
    Makie.plot(plot_grid.grid)
end

function draw_ggplot(plot_grid::GGPlotGrid, size::Tuple)
    Makie.plot(plot_grid.grid, figure=(; size=size))
end

try_convert(::Type{Any}, v, ::Any, ::Any) = v

function try_convert(T::Type, v::S, arg, fname) where {S}
    try
        retvalue = T(v)
        return retvalue
    catch
        msg = "Argument '$arg' in '$fname' has value '$v' and type '$S' which cannot be " *
              "converted to the expected type '$T'."
        throw(ArgumentError(msg))
    end
end
