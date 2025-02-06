# argument and aes conversions in draw

try_convert(::Type{Any}, v, ::Any, ::Any) = v

function try_convert(T::Type, v::S, arg, fname) where {S}
    try
        if typeof(v) == T
            return v
        end

        retvalue = typeof(v) <: T || T == Symbol ?
                   T(v) :
                   parse(T, v)
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
        f = haskey(palette, col) ?
            x -> convert_aes_type(palette[col](x),
            get(_makie_expected_type, string(col), Any), col) :
            x -> convert_aes_type(x,
            get(_makie_expected_type, string(col), Any), col)

        push!(typed_df, DataFrame(col => f(aes_df[!, col])))
    end
    return hcat(typed_df...)
end

function get_unique_labels(aes_df::DataFrame, palette::Dict)
    labels_df = DataFrame[]
    for col in Symbol.(names(aes_df))
        f = haskey(palette, col) ?
            x -> convert_aes_type(palette[col](x),
            get(_makie_expected_type, string(col), Any), col) :
            x -> convert_aes_type(x,
            get(_makie_expected_type, string(col), Any), col)

        push!(labels_df, DataFrame(
            col_name=string(col),
            original_value=aes_df[!, col],
            new_value=f(aes_df[!, col])
        ))
    end

    return unique(vcat(labels_df...))

end

# fallback methods - if there isn't a method defined, just do nothing

function convert_aes_type(aes_col::Any, ::Type{T}, col::Symbol) where {T}
    verbose[] && println("No conversion for $col: $(typeof(aes_col))")
    return aes_col
end

# aes_col is a Number

function convert_aes_type(aes_col::AbstractVector{T}, ::Type{Colors.Colorant}, col::Symbol) where {T<:Number}
    verbose[] && println("Converting $col to Colorant")
    return _default_continuous_palette(aes_col)
end

function convert_aes_type(aes_col::AbstractVector{T}, ::Type{Integer}, col::Symbol) where {T<:Number}
    verbose[] && println("Converting $col to Integer")
    return round.(Int, aes_col)
end

# aes_col is a String

function convert_aes_type(aes_col::AbstractVector{T}, ::Type{Colorant}, col::Symbol) where
{T<:AbstractString}
    verbose[] && println("Converting $col to Colorant")
    return _default_discrete_palette(aes_col)
end

function convert_aes_type(aes_col::AbstractVector{T}, ::Type{Integer}, col::Symbol) where
{T<:AbstractString}
    verbose[] && println("Converting $col to Integer")
    return levelcode.(CategoricalArray(aes_col))
end

# aes_col is a CategoricalArray

function convert_aes_type(aes_col::CategoricalArray, ::Type{Colorant}, col::Symbol)
    verbose[] && println("Converting $col to Colorant")
    return _default_discrete_palette(aes_col)
end

function convert_aes_type(aes_col::CategoricalArray, ::Type{Integer}, col::Symbol)
    verbose[] && println("Converting $col to Integer")
    return levelcode.(aes_col)
end
