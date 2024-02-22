function geom_template(name::AbstractString,
                       required_aes::AbstractArray, 
                       spec_api_function::Makie.PlotSpec;
                       dict_function::Function = identity, 
                       extra_args::Dict = Dict())

    function geom_function(args...; kwargs...)
        aes_dict, args_dict = dict_function(extract_aes(args, kwargs))
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        return build_geom(aes_dict, args_dict, 
            required_aes,
            spec_api_function)
    end

    function geom_function(plot::GGPlot, args...; kwargs...)
        aes_dict, args_dict = dict_function(extract_aes(args, kwargs))
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        return plot + build_geom(aes_dict, args_dict, 
            required_aes,
            spec_api_function)
    end

    return geom_function
end
