function ggplot(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if !haskey(args_dict, "height")
        args_dict["height"] = 400
    end
    
    if !haskey(args_dict, "width")
        args_dict["width"] = 600
    end

    if haskey(args_dict, "data")
        plot_data = AlgebraOfGraphics.data(args_dict["data"])
    else
        plot_data = mapping()
    end

    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict, 
           theme_ggplot2()) 
end

function ggplot(data::DataFrame, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if !haskey(args_dict, "height")
        args_dict["height"] = 400
    end
    
    if !haskey(args_dict, "width")
        args_dict["width"] = 600
    end

    plot_data = AlgebraOfGraphics.data(data)

    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict, 
           theme_ggplot2()) 
end
