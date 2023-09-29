function geom_template(name, required_aes, visual_layer, analysis_layer;
    dict_function = identity, extra_args = Dict())
    function geom_function(args...; kwargs...)
        plot = nothing
        
        if (length(args) != 0)
            if args[1] isa GGPlot
                plot = args[1]
            end
        end

        aes_dict, args_dict = dict_function(extract_aes(args, kwargs))
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        if !isnothing(plot)
            return plot + build_geom(aes_dict, args_dict, 
                required_aes,
                visual_layer, 
                analysis_layer) 
        else 
            return build_geom(aes_dict, args_dict, 
                required_aes,
                visual_layer, 
                analysis_layer)
        end
    end
end