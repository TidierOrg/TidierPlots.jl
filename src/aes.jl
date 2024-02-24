function aes(args...;kwargs...)
    d = Dict(kwargs)
    return Aesthetics([args...], Dict([String(key) => Symbol(d[key]) for key in keys(d)]))
end

macro aes(exprs...)
    aes_dict = Dict{String, Symbol}()
    positional = Symbol[]
    for aes_ex in exprs
        if aes_ex isa Expr
            if aes_ex.args[2] isa QuoteNode
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2].value
            elseif aes_ex.args[2] isa String
                aes_dict[String(aes_ex.args[1])] = Symbol(aes_ex.args[2])
            else
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2] 
            end
        elseif aes_ex isa Symbol
            push!(positional, aes_ex)
        elseif aes_ex isa String
            push!(positional, Symbol(aes_ex))
        end
    end
    return Aesthetics(positional, aes_dict)
end

@eval const $(Symbol("@es")) = $(Symbol("@aes"))