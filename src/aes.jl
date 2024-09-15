"""
    aes(args...; kwargs...)

# Details

TBD
"""
function aes(args...; kwargs...)
    aes_args = Pair[]
    aes_kwargs = Dict{Symbol,Pair}()

    for arg in args
        if arg isa Pair
            push!(aes_args, arg)
        else
            push!(aes_args, Symbol(arg) => identity)
        end
    end

    d = Dict(kwargs)

    for (k, v) in d
        if v isa Pair
            push!(aes_kwargs, Symbol(k) => v)
        else
            push!(aes_kwargs, Symbol(k) => Symbol(v) => identity)
        end
    end

    return Aesthetics(aes_args, aes_kwargs)
end

macro aes(exprs...)
    exprs = TidierData.parse_blocks(exprs...)
    interpolated_exprs = TidierData.parse_interpolation.(exprs)
    tidy_exprs = [i[1] for i in interpolated_exprs]
    mapping = TidierData.parse_tidy.(tidy_exprs)

    aes_args = Pair[]
    aes_kw = Dict{Symbol,Pair}()

    for aes in mapping
        if aes isa QuoteNode # positional aes with no transformations
            push!(aes_args, aes.value => identity)
        elseif aes.args[1] == :Cols
            throw("Calculations are not supported in positional aes specs.")
        elseif aes.args[2] isa QuoteNode
            push!(aes_kw, aes.args[3].value => aes.args[2].value => identity)
        else
            tf = eval(aes)
            push!(aes_kw, tf[2][2] => tf[1] => tf[2][1])
        end
    end

    return Aesthetics(aes_args, aes_kw)
end

function Base.show(io::IO, aes::Aesthetics)
    println("A TidierPlots aes mapping object.")
    println("Positional:")

    for pos in aes.positional
        println(pos)
    end

    println("Named:")

    for (k, v) in aes.named
        println("$k : $v")
    end
end
