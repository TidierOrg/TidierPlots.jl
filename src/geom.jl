function build_geom(
    aes_dict,
    args_dict,
    required_aes,
    spec_api_function;
    pre_function=do_nothing,
    post_function=do_nothing,
    special_aes=Dict(),
    grouping_aes=Symbol[])

    if haskey(args_dict, "data")
        if args_dict["data"] isa DataFrame
            plot_data = args_dict["data"]
        else
            throw(ArgumentError("Data should be provided as a DataFrame, not as a $(typeof(args_dict["data"]))"))
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
        AxisOptions(Dict(), Dict(), Dict()),
        pre_function,
        post_function,
        grouping_aes
    )
end
