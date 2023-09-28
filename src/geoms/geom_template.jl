function geom_template(name, required_aes, visual_layer, analysis_layer)
    function geom_function(args...; kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        args_dict["geom_name"] = name
        return build_geom(aes_dict, args_dict, 
            required_aes,
            visual_layer, 
            analysis_layer) 
    end
end