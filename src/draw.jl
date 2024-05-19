import Makie.SpecApi

function Makie.SpecApi.Axis(plot::GGPlot)
    plot_list = Makie.PlotSpec[]
    plot_list_by_facet = nothing
    facet_names = nothing
    facet_positions = nothing
    facet_boxes = Dict()
    facet_labels = Dict()
    axis_options = Dict{Symbol, Any}()

    ymin = Inf
    xmin = Inf
    xmax = -Inf
    ymax = -Inf

    for geom in plot.geoms
        # use the dataframe specified in the geom if present, otherwise use the ggplot one
        plot_data = isnothing(geom.data) ? plot.data : geom.data

        # inherit any aes specified at the ggplot level, unless inherit_aes is false
        if get(geom.args, "inherit_aes", true)
            aes_dict = merge(plot.default_aes, geom.aes)
        else
            aes_dict = geom.aes
        end

        # apply function if required to edit the aes/args/data
        aes_dict, args_dict, required_aes, plot_data =
            geom.aes_function(aes_dict, geom.args, geom.required_aes, plot_data)

        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_geom = merge(_ggplot_to_makie, geom.special_aes)

        # given_aes will store the data for each given aes
        given_aes = Dict{Symbol, PlottableData}()

        # inherit any unspecified column transforms
        col_transforms = merge(geom.column_transformations, plot.column_transformations)

        aes_dict_makie = Dict{Symbol, Symbol}()

        for (aes_string, column_name) in aes_dict
            # the name of the aes is translated to the makie term if needed
            aes = get(ggplot_to_makie_geom, aes_string, aes_string)
            push!(aes_dict_makie, Symbol(aes) => column_name)
        end

        for (aes, column_name) in aes_dict_makie
            # if there is a specified column transformation, use it
            # otherwise use cat_inseq for string-like columns and as_is for everything else
            if haskey(col_transforms, aes)
                source_cols = [aes_dict_makie[source] for source in col_transforms[aes][1]]
                plottable_data = col_transforms[aes][2](aes, source_cols, plot_data)
            elseif eltype(plot_data[!, column_name]) <: Union{AbstractString, AbstractChar}
                plottable_data = cat_inseq(aes, [column_name], plot_data)
                if aes in [:color, :fill]
                    plottable_data[aes] = as_color(plottable_data[aes])
                end
            else
                plottable_data = as_is(aes, [column_name], plot_data)
            end

            # if the transform has a label associated with it, pass that into axis_options
            if haskey(plottable_data, aes) && !isnothing(plottable_data[aes].label_target)
                axis_options[plottable_data[aes].label_target] = plottable_data[aes].label_function(plottable_data[aes].raw)
            end

            # add the transformed data to list to eventually be passed to the plot args/kwargs
            merge!(given_aes, plottable_data)
        end

        args_dict_makie = Dict{Symbol, Any}()

        for (arg, value) in args_dict
            if !(arg in _internal_geom_options) 
                ex_type = get(_makie_expected_type, arg, Any)
                converted_value = try_convert(ex_type, value, arg, geom.args["geom_name"])
                makie_attr = get(ggplot_to_makie_geom, arg, arg)
                args_dict_makie[Symbol(makie_attr)] = converted_value
            end
        end

        # keep track of the global max and min on each axis
        if haskey(given_aes, :x)
            xmin = min(xmin, minimum(given_aes[:x].makie_function(given_aes[:x].raw)))
            xmax = max(xmax, maximum(given_aes[:x].makie_function(given_aes[:x].raw)))
        end

        if haskey(given_aes, :y)
            ymin = min(ymin, minimum(given_aes[:y].makie_function(given_aes[:y].raw)))
            ymax = max(ymax, maximum(given_aes[:y].makie_function(given_aes[:y].raw)))
        end

        if length(intersect(keys(given_aes), geom.grouping_aes)) == 0 && isnothing(plot.facet_options) 
            # if there are no grouping_aes given and no facets required, we only need one PlotSpec
            required_aes_data = [p.makie_function(p.raw) for p in [given_aes[a] for a in Symbol.(required_aes)]]
            optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in given_aes if !(String(a) in required_aes)]

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
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if !(String(a) in required_aes)]

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
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if !(String(a) in required_aes)]

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
                optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in sub if !(String(a) in required_aes)]
    
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
        if !(arg in _internal_geom_options) 
            ex_type = get(_makie_expected_type, arg, Any)
            converted_value = try_convert(ex_type, value, arg, "ggplot")
            makie_attr = get(_ggplot_to_makie, arg, arg)
            axis_options[Symbol(makie_attr)] = converted_value
        end
    end

    if isnothing(plot.facet_options) 
        return length(axis_options) == 0 ?
            Makie.SpecApi.Axis(plots = plot_list) :
            Makie.SpecApi.Axis(plots = plot_list; axis_options...)
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
                [facet_positions[name] => Makie.SpecApi.Axis(plots = plot_list_by_facet[name]) for name in facet_names]...,
                facet_labels...,
                facet_boxes...
            )          
        else
            return Makie.SpecApi.GridLayout(
                [facet_positions[name] => Makie.SpecApi.Axis(plots = plot_list_by_facet[name]; axis_options...) for name in facet_names]...,
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

function draw_ggplot(plot_grid::GGPlotGrid)
    Makie.plot(plot_grid.grid)
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
