# argument and aes conversions in draw

try_convert(::Type{Any}, v, ::Any, ::Any) = v

function try_convert(T::Type, v::S, arg, fname) where {S}
    try
        retvalue = T(v)
        return retvalue
    catch
        msg = "Argument '$arg' in '$fname' has value '$v' and type '$S' which cannot be " *
              "converted to the expected type '$T'."
        throw(ArgumentError(msg))
    end
end

function convert_aes_df_types(aes_df::DataFrame, palette::Dict)
    typed_df = DataFrame[]
    for col in Symbol.(names(aes_df))
        f = haskey(palette, col) ? palette[col] :
            x -> convert_aes_type(x,
                get(_makie_expected_type, string(col), Any))

        push!(typed_df, DataFrame(col => f(aes_df[!, col])))
    end
    return hcat(typed_df...)
end

# fallback methods - if there isn't a method defined, just do nothing

function convert_aes_type(aes_col::Any, ::Type{T}) where {T}
    return aes_col
end

# aes_col is a Number

function convert_aes_type(aes_col::Vector{Number}, ::Type{Colorant})
    return _default_continuous_palette(aes_col)
end

function convert_aes_type(aes_col::Vector{Number}, ::Type{Integer})
    return round.(aes_col)
end

# aes_col is a String

function convert_aes_type(aes_col::Vector{AbstractString}, ::Type{Colorant})
    return _default_discrete_palette(aes_col)
end

function convert_aes_type(aes_col::Vector{AbstractString}, ::Type{Integer})
    return levelcode.(CategoricalArray(aes_col))
end

# aes_col is a CategoricalArray

function convert_aes_type(aes_col::CategoricalArray, ::Type{Colorant})
    return _default_discrete_palette(aes_col)
end

function convert_aes_type(aes_col::CategoricalArray, ::Type{Integer})
    return levelcode.(aes_col)
end
