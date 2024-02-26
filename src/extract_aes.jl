function extract_aes(args, kwargs)
    aes_dict = Dict{String, Symbol}() 
    args_dict = Dict{String, Any}() 

    for arg in args
        if arg isa DataFrame
            args_dict["data"] = arg
        elseif arg isa Aesthetics
            aes_dict = merge(aes_dict, arg.aes)
        end
    end

    d = Dict(kwargs)
    args_dict = merge(args_dict, Dict([String(key) => d[key] for key in keys(d)]))

    return (aes_dict, args_dict)
end   

function make_aes_extractor(required_aes)
    return function extract_aes(args, kwargs)
        aes_dict = Dict{String, Symbol}() 
        args_dict = Dict{String, Any}() 

        for arg in args
            if arg isa DataFrame
                args_dict["data"] = arg
            elseif arg isa Aesthetics
                if length(arg.positional) != 0
                    for (i, pos_arg) in enumerate(arg.positional)
                        if haskey(arg.named, required_aes[i])
                            bad_aes = required_aes[i]
                            @error "Required aes ($bad_aes) given both positionally and by name. Choose one or the other."
                        end
                        push!(aes_dict, required_aes[i] => pos_arg)
                    end
                end  
                aes_dict = merge(aes_dict, arg.named)
            end
        end

        d = Dict(kwargs)
        args_dict = merge(args_dict, Dict([String(key) => d[key] for key in keys(d)]))

        return (aes_dict, args_dict)
    end
end    
