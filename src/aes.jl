function aes(;kwargs...)
    d = Dict(kwargs)
    return Aesthetics(Dict([String(key) => Symbol(d[key]) for key in keys(d)]))
end

macro aes(exprs...)
    aes_dict = Dict{String, Symbol}()
    for aes_ex in exprs
        if aes_ex isa Expr
            if aes_ex.args[2] isa QuoteNode
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2].value
            else
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2] 
            end
        end
    end
    return Aesthetics(aes_dict)
end

macro es(exprs...)
    aes_dict = Dict{String, Symbol}()
    for aes_ex in exprs
        if aes_ex isa Expr
            if aes_ex.args[2] isa QuoteNode
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2].value
            else
                aes_dict[String(aes_ex.args[1])] = aes_ex.args[2] 
            end
        end
    end
    return Aesthetics(aes_dict)
end 