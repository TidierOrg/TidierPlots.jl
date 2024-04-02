import Makie.SpecApi

function Makie.SpecApi.Axis(plot::GGPlot)
     # translation dict for GGPlot term => Makie Term
    # terms that aren't on this list won't be translated, just passed directly to Makie
    ggplot_to_makie = Dict{String, String}(
        "colour" => "color",
        "shape" => "marker",
        "size" => "markersize",
        "stroke" => "strokewidth",
        "strokecolour" => "strokecolor",
        "linetype" => "linestyle",
        "glow" => "glowwidth",
        "glowcolour" => "glowcolor",
        "errorbar_direction" => "direction",
        "label" => "text",
        "palette" => "colormap"
    )

    # What type does the Makie argument expect? 
    # without a specified type here, arguments will pass "as is"
    
    expected_type = Dict{String, Type}(
        # Symbol
        "marker"        => Symbol,
        "strokecolor"   => Symbol,
        "glowcolor"     => Symbol,
        "colormap"      => Symbol,
        "yaxisposition" => Symbol,
        "direction"     => Symbol,
        # Float
        "alpha"         => Float32,
        "markersize"    => Float32,
        "strokewidth"   => Float32,
        "glowwidth"     => Float32,
        # Integer
        "bins"          => Int64
    )

    plot_list = Makie.PlotSpec[]
    axis_options = Dict{Symbol, Any}()

    for geom in plot.geoms
        # use the dataframe specified in the geom if present, otherwise use the ggplot one
        plot_data = isnothing(geom.data) ? plot.data : geom.data

        # inherit any aes specified at the ggplot level
        aes_dict = merge(plot.default_aes, geom.aes)

        # apply function if required to edit the aes/args/data
        aes_dict, args_dict, required_aes, plot_data = 
            geom.aes_function(aes_dict, geom.args, geom.required_aes, plot_data)
        
        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_geom = merge(ggplot_to_makie, geom.special_aes)
        
        # which optional aesthetics were given?
        optional_aes_given = [k for (k, v) in aes_dict if !(k in required_aes)]
        visual_optional_aes = Dict{Symbol, Any}()
        
        for a in optional_aes_given
            # the name of the aes is translated to the makie term if needed
            aes = haskey(ggplot_to_makie_geom, a) ? Symbol(ggplot_to_makie_geom[a]) : Symbol(a)

            # if there is a specified column transformation, use it
            # otherwise use cat_inseq for string-like columns and as_is for everything else
            if haskey(geom.column_transformations, aes)
                plottable_data = geom.column_transformations[aes][2](aes, geom.column_transformations[aes][1], plot_data)
            elseif eltype(plot_data[!, aes_dict[a]]) <: Union{AbstractString, AbstractChar}
                plottable_data = cat_inseq(aes, [aes_dict[a]], plot_data)
            else
                plottable_data = as_is(aes, [aes_dict[a]], plot_data)
            end

            # if the transform has a label associated with it, pass that into axis_options
            if !isnothing(plottable_data[aes].label_target)
                axis_options[plottable_data[aes].label_target] = plottable_data[aes].label_function(plottable_data[aes].raw)
            end

            # add the transformed data to list to eventually be passed to the plots kwargs
            push!(visual_optional_aes, aes => plottable_data[aes].makie_function(plottable_data[aes].raw))
        end

        # which ones were given as arguments? 

        args_dict_makie = Dict{Symbol, Any}()

        for (arg, value) in args_dict
            if haskey(expected_type, arg)
                try
                    if haskey(ggplot_to_makie_geom, arg)
                        args_dict_makie[Symbol(ggplot_to_makie_geom[arg])] = expected_type[arg](value)
                    else
                        args_dict_makie[Symbol(arg)] = expected_type[arg](value)
                    end
                catch
                    ex_type = expected_type[arg]
                    given_type = typeof(args_dict[arg])
                    geom_name = geom.args["geom_name"]
                    @error "Argument $arg in $geom_name given as type $given_type, 
                            which cannot be converted to expected type $ex_type."
                end
            end
        end
        
        # make a Tuple that contains the columns from the data in their required order to pass to PlotSpec
        visual_args_list = []

        for a in required_aes
            aes = Symbol(a)
            # if there is a specified column transformation, use it
            # otherwise use cat_inseq for string-like columns and as_is for everything else
            if haskey(geom.column_transformations, aes)
                plottable_data = geom.column_transformations[aes][2](aes, geom.column_transformations[aes][1], plot_data)
            elseif eltype(plot_data[!, aes_dict[a]]) <: Union{AbstractString, AbstractChar}
                plottable_data = cat_inseq(aes, [aes_dict[a]], plot_data)
            else
                plottable_data = as_is(aes, [aes_dict[a]], plot_data)
            end

            # if the transform has a label associated with it, pass that into axis_options
            if !isnothing(plottable_data[aes].label_target)
                axis_options[plottable_data[aes].label_target] = plottable_data[aes].label_function(plottable_data[aes].raw)
            end
            push!(visual_args_list, plottable_data[aes].makie_function(plottable_data[aes].raw))
        end

        args = Tuple([geom.visual, visual_args_list...])
        kwargs = merge(args_dict_makie, visual_optional_aes)

        # push completed PlotSpec (type, args, and kwargs) to the list of plots

        push!(plot_list, Makie.PlotSpec(args...; kwargs...))
    end

    # rename and correct types on all axis options

    for (arg, value) in plot.axis_options
        if haskey(expected_type, arg)
            value = expected_type[arg](value)
        end

        try
            if haskey(ggplot_to_makie, arg)
                axis_options[Symbol(ggplot_to_makie[arg])] = value
            else
                axis_options[Symbol(arg)] = value
            end
        catch
            ex_type = expected_type[arg]
            given_type = typeof(args_dict[arg])
            @error "Argument $arg in ggplot() given as type $given_type, which cannot be converted to expected type $ex_type."
        end
    end

    return length(axis_options) == 0 ? 
        Makie.SpecApi.Axis(plots = plot_list) :
        Makie.SpecApi.Axis(
                plots = plot_list; 
                axis_options...
            )
end

function draw_ggplot(plot::GGPlot)
    axis = Makie.SpecApi.Axis(plot)

    Makie.plot(
        Makie.SpecApi.GridLayout(
            axis
        )
    )
end

function draw_ggplot(plot_grid::GGPlotGrid)
    Makie.plot(plot_grid.grid)
end