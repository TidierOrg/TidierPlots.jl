function geom_template(name::AbstractString,
                       required_aes::AbstractArray, 
                       spec_api_function::Symbol;
                       aes_function::Function = identity, 
                       extra_args::Dict = Dict())

    function geom_function(args...; kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        aes_dict, args_dict, required_aes = dict_function(aes_dict, args_dict, required_aes)
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        return build_geom(aes_dict, args_dict, 
            required_aes,
            spec_api_function,
            aes_function)
    end

    function geom_function(plot::GGPlot, args...; kwargs...)
        return plot + geom_function(args...; kwargs...)
    end

    return geom_function
end
