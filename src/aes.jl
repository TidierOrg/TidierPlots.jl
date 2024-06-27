"""
    aes(args...; kwargs...)

# Details

TBD
"""
function aes(args...; kwargs...)
    col_transforms = Dict()
    aes_args = Symbol[]
    aes_kwargs = Dict{String, Union{Symbol, Pair}}()

    for arg in args
        if arg isa Pair
            @error "Calculated columns currently do not support positional aes specification."
        else
            push!(aes_args, Symbol(arg))
        end
    end

    d = Dict(kwargs)

    for (k, v) in d
        if v isa Pair
            push!(aes_kwargs, String(k) => v)
        else
            push!(aes_kwargs, String(k) => Symbol(v))
        end
    end

    return Aesthetics(
            aes_args,
            aes_kwargs,
            col_transforms)
end

macro aes(exprs...)
    aes_dict = Dict{String, Union{Symbol, Any}}()
    positional = Symbol[]
    for aes_ex in exprs
        if aes_ex isa Expr
            if aes_ex.args[2] isa Expr
                tidy = TidierData.parse_tidy(aes_ex)
                aes_dict[String(aes_ex.args[1])] = tidy.args[2] => eval(tidy.args[3])[1]
            elseif aes_ex.args[2] isa QuoteNode
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
    return Aesthetics(positional, aes_dict, Dict())
end

@eval const $(Symbol("@es")) = $(Symbol("@aes"))
