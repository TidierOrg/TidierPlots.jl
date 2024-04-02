function geom_template(name::AbstractString,
                       required_aes::AbstractArray, 
                       spec_api_function::Symbol;
                       aes_function::Function = do_nothing,
                       column_transformations::Dict{Symbol, Pair{Vector{Symbol}, Function}} = Dict{Symbol, Pair{Vector{Symbol}, Function}}(), 
                       extra_args::Dict = Dict())

    extract_geom_aes = make_aes_extractor(required_aes)

    function geom_function(args...; kwargs...)
        aes_dict, args_dict = extract_geom_aes(args, kwargs)
        args_dict["geom_name"] = name
        args_dict = merge(args_dict, extra_args)

        return build_geom(aes_dict, args_dict, 
            required_aes,
            spec_api_function,
            aes_function, 
            column_transformations)
    end

    function geom_function(plot::GGPlot, args...; kwargs...)
        return plot + geom_function(args...; kwargs...)
    end

    return geom_function
end
