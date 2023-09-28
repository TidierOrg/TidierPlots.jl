function geom_template(name, required_aes, visual_layer, analysis_layer;
                       dict_function = identity, extra_args = Dict())
    function geom_function(args...; kwargs...)
        aes_dict, args_dict = dict_function(extract_aes(args, kwargs))
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        return build_geom(aes_dict, args_dict, 
            required_aes,
            visual_layer, 
            analysis_layer) 
    end
end