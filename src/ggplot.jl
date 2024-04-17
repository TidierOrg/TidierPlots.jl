function ggplot(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if haskey(args_dict, "data")
        if args_dict["data"] isa DataFrame
            plot_data = args_dict["data"]
            delete!(args_dict, "data")
        else
            type = typeof(args_dict["data"])
            @warn "Data was provided in ggplot function with unsupported type: $type. Data argument ignored."
            plot_data = nothing
        end
    else
        plot_data = nothing
    end

    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict, 
           theme_ggplot2(),
           Dict(),
           Dict()) 
end

function ggplot(data::DataFrame, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    GGPlot([], 
           aes_dict, 
           data,
           args_dict, 
           theme_ggplot2(),
           Dict(),
           Dict()) 
end
