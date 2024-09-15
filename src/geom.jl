function build_geom(
        aes_dict,
        args_dict,
        required_aes,
        spec_api_function,
        aes_function;
        special_aes = Dict(),
        grouping_aes = Symbol[])

    if haskey(args_dict, "data")
        if args_dict["data"] isa DataFrame
            plot_data = args_dict["data"]
        else
            type = typeof(args_dict["data"])
            geom_name = args_dict["geom_name"]
            @warn "Data was provided in $geom_name with unsupported type: $type. Data argument ignored."
            plot_data = nothing
        end
    else
        plot_data = nothing
    end

    # return a geom object
    return Geom(
        aes_dict,
        args_dict,
        required_aes,
        special_aes,
        plot_data,
        spec_api_function,
        Dict(),
        aes_function,
        grouping_aes
    )
end
