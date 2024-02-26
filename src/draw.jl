function draw_ggplot(plot::GGPlot)
    
    # translation dict for GGPlot term => Makie Term
    optional_aes = Dict{String, String}(
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
    expected_type = Dict{String, Type}(
        "marker" => Symbol,
        "markersize" => Float32,
        "strokewidth" => Float32,
        "strokecolor" => Symbol,
        "glowwidth" => Float32,
        "glowcolor" => Symbol,
        "colormap" => Symbol,
        "alpha" => Float32
    )

    plot_list = Makie.PlotSpec[]

    for geom in plot.geoms
        # use the dataframe specified in the geom if present, otherwise default to the ggplot one
        plot_data = isnothing(geom.data) ? plot.data : geom.data

        # inherit any aes specified at the ggplot level
        aes_dict = merge(plot.default_aes, geom.aes)

        # check to make sure all required aesthetics are available
        check_aes(geom.required_aes, aes_dict, geom.args["geom_name"]) 

        # apply function if required to edit the aes
        aes_dict, args_dict, required_aes, plot_data = 
            geom.aes_function(aes_dict, geom.args, geom.required_aes, plot_data)
        
        # make a master list of all possible accepted optional aesthetics and args
        ggplot_to_makie_dict = merge(optional_aes, geom.special_aes)
        
        # which optional aesthetics were given?
        optional_aes_given = [k for (k, v) in aes_dict if !(k in geom.required_aes)]

        visual_optional_aes = Dict{Symbol, Any}()
        
        for a in optional_aes_given
            if has_key(ggplot_to_makie_dict, a)
                aes = Symbol(ggplot_to_makie_dict[a])
            else
                aes = Symbol(a)
            end
            
            if eltype(plot_data[!, aes_dict[a]]) <: AbstractString
                cat_array = CategoricalArray(plot_data[!, aes_dict[a]])
                column_data = levelcode.(cat_array)
                labels = levels(cat_array)
                args_dict[a * "ticks"] = (1:length(labels), labels)
            else
                column_data = plot_data[!, aes_dict[a]]
            end

            push!(visual_optional_aes, aes => column_data)
        end

        # which ones were given as arguments? 
        args_given = intersect(
            keys(args_dict),
            keys(optional_visual_args)
        )
        
        # make a Dict that has the kwargs
        visual_args = Dict(Symbol(optional_visual_args[a]) => args_dict[a] for a in args_given)

        kwargs = (;merge(visual_args, visual_optional_aes)...)
        
        # make a Tuple that contains the columns from the data in their required order to pass to PlotSpec
        visual_args_list = []

        for req_aes in required_aes
            if eltype(plot_data[!, aes_dict[req_aes]]) <: AbstractString
                cat_array = CategoricalArray(plot_data[!, aes_dict[req_aes]])
                column_data = levelcode.(cat_array)
                labels = levels(cat_array)
                args_dict[req_aes * "ticks"] = (1:length(labels), labels)
            else
                column_data = plot_data[!, aes_dict[req_aes]]
            end
            push!(visual_args_list, column_data)
        end
        
        args = Tuple(visual_args_list)
        
        # push completed PlotSpec (type, args, and kwargs) to the list of plots
        push!(plot_list, Makie.PlotSpec(geom.visual, args...; kwargs...))
    end

    println(plot.axis_options)

    Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = plot_list; [Symbol(k) => v for (k, v) in plot.axis_options]...
            )
        )
    )
    
end