macro ggplot(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    if !haskey(args_dict, "height")
        args_dict["height"] = 400
    end
    
    if !haskey(args_dict, "width")
        args_dict["width"] = 600
    end

    if haskey(args_dict, "data")
        # if the code is running in a Pluto.jl notebook
        if !isnothing(match(r"#==#", @__FILE__))
            plot_data = AlgebraOfGraphics.data(eval(args_dict["data"]))
        else
            plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"]))
        end
    else
        plot_data = mapping()
    end

    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict) 
end

function ggplot(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if !haskey(args_dict, "height")
        args_dict["height"] = 400
    end
    
    if !haskey(args_dict, "width")
        args_dict["width"] = 600
    end

    # if data is specified, call a questionable eval to grab it as a layer
    if haskey(args_dict, "data")
        # if the code is running in a Pluto.jl notebook
        if args_dict["data"] isa DataFrame
            plot_data = AlgebraOfGraphics.data(args_dict["data"])
        elseif args_dict["data"] isa Symbol
            plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"]))
        elseif args_dict["data"] isa AbstractString
            plot_data = AlgebraOfGraphics.data(Base.eval(Main, Symbol(args_dict["data"])))
        else
            type = typeof(args_dict["data"])
            @error "Data was provided in an unsupported type: $type"
        end
    else
        plot_data = mapping()
    end

    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict) 
end