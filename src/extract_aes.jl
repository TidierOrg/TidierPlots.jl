function extract_aes(geom)
    aes_dict = Dict{String, Symbol}() 
    args_dict = Dict{String, Any}() 

    for section in geom
        if section isa Expr
            # if the section is an expression, check if it is a aes function call
            if section.args[1] == :aes
                for aes_ex in section.args
                    if aes_ex isa Expr
                        if aes_ex.args[2] isa QuoteNode
                            aes_dict[String(aes_ex.args[1])] = aes_ex.args[2].value
                        else
                            aes_dict[String(aes_ex.args[1])] = aes_ex.args[2] 
                        end
                    end
                end
            elseif section.args[1] == :c
                args_dict["values"] = [v for v in section.args[2:end]] 
            # if not, its a generic argument
            else
                if section.args[2] isa QuoteNode
                    args_dict[String(section.args[1])] = section.args[2].value
                else 
                    args_dict[String(section.args[1])] = section.args[2]
                end
            end
        elseif section isa Symbol
            # if the section is a symbol, assume it is meant to be the data argument
            args_dict["data"] = section
        end
    end

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
