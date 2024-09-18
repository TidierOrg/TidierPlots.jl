import Makie.SpecApi

function Makie.SpecApi.Axis(plot::GGPlot)
    plot_list = Dict{Tuple,Vector{Makie.PlotSpec}}()
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
            geom.pre_function(aes_dict, geom.args, geom.required_aes, plot_data)

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

        if !isnothing(plot.facet_options)
            push!(aes_df_list,
                DataFrame(facet = plot_data[!, plot.facet_options.wrap]))
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

        args_dict_makie = Dict{Symbol,Any}()

        supported_kwargs = get(_accepted_options_by_type, geom.visual,
            nothing)

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

        # after all edits have been made, apply the post_function

        aes_dict, args_dict, required_aes, aes_df =
            geom.post_function(aes_dict,
                args_dict,
                required_aes,
                aes_df)


        if !isnothing(plot.color_palette)
            if eltype(aes_df.color) <: Number
                aes_df = transform(aes_df, :color =>
                    plot.color_palette => :color)
            else
                aes_df = transform(aes_df, :color =>
                    (x -> plot.color_palette.(
                        levelcode.(
                            CategoricalArray(x)
                        )
                    )) => :color
                )
            end
        elseif "color" in names(aes_df)
            if eltype(aes_df.color) <: Number
                aes_df = transform(aes_df, :color =>
                    _default_continuous_palette => :color)
            else
                aes_df = transform(aes_df, :color =>
                    (x -> _default_discrete_palette(
                        levelcode.(
                            CategoricalArray(x)
                        )
                    )) => :color
                )
            end
        end

        # keep track of the global max and min on each axis
        if "x" in names(aes_df) && eltype(aes_df.x) <: Number
            xmin = min(xmin, minimum(aes_df.x))
            xmax = max(xmax, maximum(aes_df.x))
        end

        if "y" in names(aes_df) && eltype(aes_df.y) <: Number
            ymin = min(ymin, minimum(aes_df.y))
            ymax = max(ymax, maximum(aes_df.y))
        end

        # if there are no facet options just plot everything in 1,1
        # if there are, make a column that indicates which facet each point belongs to
        if isnothing(plot.facet_options)
            aes_df.facet .= [(1, 1)] # everything goes in the same "facet"
        else
            facet_names = unique(aes_df.facet)
            facet_positions, facet_labels, facet_boxes =
                position_facets(facet_names,
                    plot.facet_options.nrow,
                    plot.facet_options.ncol)
            aes_df.facet = [facet_positions[k] for k in aes_df.facet]
        end

        for (key, group_aes_df) in pairs(groupby(aes_df, [:group, :facet]))
            required_aes_data = []

            for a in required_aes
                data = group_aes_df[!, Symbol(a)]
                if !(Symbol(a) in _verbatim_aes)
                    if eltype(data) <: AbstractString
                        labels = levels(CategoricalArray(data))
                        data = levelcode.(CategoricalArray(data))
                        axis_options[Symbol(a * "ticks")] = (
                            1:maximum(data),
                            string.(labels)
                        )
                    elseif eltype(data) <: CategoricalValue
                        labels = levels(data)
                        data = levelcode.(data)
                        axis_options[Symbol(a * "ticks")] = (
                            1:maximum(data),
                            string.(labels)
                        )
                    end
                else
                    data = String.(data)
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

                if eltype(data) <: Union{AbstractString,RGB{FixedPoint}}
                    if !(Symbol(a) in _verbatim_aes)
                        data = Categorical(data)
                    else
                        data = String.(data)
                    end
                end

                push!(optional_aes_data, Symbol(a) => data)
            end

            args = Tuple([geom.visual, required_aes_data...])
            kwargs = merge(args_dict_makie, optional_aes_data)

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

        if !plot.facet_options.free_x && plot.facet_options.free_y
            expandx = (xmax - xmin) * 0.05
            axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), nothing)
        elseif plot.facet_options.free_x && !plot.facet_options.free_y
                axis_options[:limits] = (nothing, (ymin - expand_y, ymax + expand_y))
        elseif !plot.facet_options.free_x && !plot.facet_options.free_y
                axis_options[:limits] = ((xmin - expand_x, xmax + expand_x), (ymin - expand_y, ymax + expand_y))
        end
    end

    return Makie.SpecApi.GridLayout(
        [k => Makie.SpecApi.Axis(plots=v; axis_options...) for
            (k, v) in plot_list]...,
        facet_labels...,
        facet_boxes...
    )
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
