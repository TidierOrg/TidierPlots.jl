function geom_errorbar(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbar"
    
    return build_geom(aes_dict, args_dict, 
        ["x", "ymin", "ymax"], # required aesthetics
        :Rangebars, # function for visual layer
        do_nothing,
        Dict{Symbol, Function}();
        special_aes = Dict("width" => "whiskerwidth")) 
end

function geom_errorbarh(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbarh"
    args_dict["errorbar_direction"] = :x

    return build_geom(aes_dict, args_dict, 
        ["y", "xmin", "xmax"], # required aesthetics
        :Rangebars, # function for visual layer
        do_nothing,
        Dict{Symbol, Function}();
        special_aes = Dict("width" => "whiskerwidth")) 

end

function geom_errorbarh(plot::GGPlot, args...; kwargs...)
    return plot + geom_errorbarh(args..., kwargs...)
end

function geom_errorbar(plot::GGPlot, args...; kwargs...)
    return plot + geom_errorbar(args..., kwargs...)
end