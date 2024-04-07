function make_aes_extractor(required_aes)
    return function extract_aes(args, kwargs)
        aes_dict = Dict{String, Symbol}() 
        args_dict = Dict{String, Any}() 
        transforms = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}()

        for arg in args
            if arg isa DataFrame
                args_dict["data"] = arg
            elseif arg isa Aesthetics
                if length(arg.positional) != 0
                    if length(required_aes) == 0
                        @error "Positional aes detected, but meaning is ambiguous. Please use aes names in your aes call (e.g. @aes(x = x) instead of @aes(x))."
                    end

                    for (i, pos_arg) in enumerate(arg.positional)
                        if haskey(arg.named, required_aes[i])
                            bad_aes = required_aes[i]
                            @error "Required aes ($bad_aes) given both positionally and by name. Choose one or the other."
                        end
                        push!(aes_dict, required_aes[i] => pos_arg)
                    end
                end  
                merge!(aes_dict, arg.named)
                merge!(transforms, arg.column_transformations)
            end
        end

        d = Dict(kwargs)
        args_dict = merge(args_dict, Dict([String(key) => d[key] for key in keys(d)]))

        return (aes_dict, args_dict, transforms)
    end
end    

extract_aes = make_aes_extractor([])
