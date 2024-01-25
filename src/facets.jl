function facet_grid(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    
    if length(args) == 2
        aes_dict["row"] = Symbol(args[1])
        aes_dict["col"] = Symbol(args[2])
    elseif length(args) == 1
        aes_dict["col"] = Symbol(args[1])
    else
        if haskey(args_dict, "rows")
            aes_dict["row"] = Symbol(args_dict["rows"])
        end
        if haskey(args_dict, "cols")
            aes_dict["col"] = Symbol(args_dict["cols"])
        end
    end
    
    return Aesthetics(aes_dict)
end


function facet_wrap(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if length(args) == 1
        aes_dict["layout"] = Symbol(args[1])
    elseif haskey(args_dict, "facets")
        aes_dict["layout"] = Symbol(args_dict["facets"])
    end
    
    return Aesthetics(aes_dict)
end

function facet_wrap(plot::GGPlot, args...; kwargs...)    
    return plot + facet_wrap(args...; kwargs...)
end

function facet_grid(plot::GGPlot, args...; kwargs...)    
    return plot + facet_grid(args...; kwargs...)
end