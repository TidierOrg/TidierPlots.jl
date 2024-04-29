import Makie.SpecApi

function Makie.SpecApi.Axis(plot::GGPlot)
    plot_list = Makie.PlotSpec[]
    axis_options = Dict{Symbol, Any}()

    for geom in plot.geoms
        # use the dataframe specified in the geom if present, otherwise use the ggplot one
        plot_data = isnothing(geom.data) ? plot.data : geom.data

        # inherit any aes specified at the ggplot level, unless inherit_aes is false
        if get(geom.args_dict, :inherit_aes, true)
            aes_dict = merge(plot.default_aes, geom.aes)
        else
            aes_dict = geom.aes
        end

        # apply function if required to edit the aes/args/data
        aes_dict, args_dict, required_aes, plot_data =
            geom.aes_function(aes_dict, geom.args, geom.required_aes, plot_data)

        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_geom = merge(_ggplot_to_makie, geom.special_aes)

        # which aesthetics were given?
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

        required_aes_data = [p.makie_function(p.raw) for p in [given_aes[a] for a in Symbol.(required_aes)]]
        optional_aes_data = [a => p.makie_function(p.raw) for (a, p) in given_aes if !(String(a) in required_aes)]

        args = Tuple([geom.visual, required_aes_data...])
        kwargs = merge(args_dict_makie, Dict(optional_aes_data))

        # push completed PlotSpec (type, args, and kwargs) to the list of plots
        push!(plot_list, Makie.PlotSpec(args...; kwargs...))
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

    return length(axis_options) == 0 ?
        Makie.SpecApi.Axis(plots = plot_list) :
        Makie.SpecApi.Axis(plots = plot_list; axis_options...)
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
