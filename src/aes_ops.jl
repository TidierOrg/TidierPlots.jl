import Base.:>> 

Base.:>>(sym::Symbol, fn::Function) = aesthetics_function(fn)(sym)

# 'rithm'tic (dubious implementation)

import Base.:+

function add_cols_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    result = data[!, source[1]] .+ data[!, source[2]]
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            result,        
            identity,                
            nothing,            
            nothing                   
        )
    )
end

function make_add_const_function(constant::Real)
    return function add_const_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        result = data[!, source[1]] .+ constant
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                result,        # get the column out of the dataframe
                identity,      # apply generic_fn to it
                nothing,            
                nothing                   
            )
        )
    end
end

Base.:+(s1::Symbol, s2::Symbol) = [s1, s2] => AesTransform(add_cols_fn)
Base.:+(s1::Symbol, s2::Real) = [s1] => AesTransform(make_add_const_function(s2))
Base.:+(s2::Real, s1::Symbol) = [s1] => AesTransform(make_add_const_function(s2))

import Base.:-

function subtract_cols_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    result = data[!, source[1]] .- data[!, source[2]]
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            result,        
            identity,                
            nothing,            
            nothing                   
        )
    )
end

function make_subtract_const_function(constant::Real)
    return function add_const_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        result = constant .- data[!, source[1]]
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                result,        # get the column out of the dataframe
                identity,      # apply generic_fn to it
                nothing,            
                nothing                   
            )
        )
    end
end

Base.:-(s1::Symbol, s2::Symbol) = [s1, s2] => AesTransform(subtract_cols_fn)
Base.:-(s1::Symbol, s2::Real) = [s1] => AesTransform(make_add_const_function(-s2))
Base.:-(s2::Real, s1::Symbol) = [s1] => AesTransform(make_subtract_const_function(s2))

import Base.:*

function multiply_cols_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    result = data[!, source[1]] .* data[!, source[2]]
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            result,        
            identity,                
            nothing,            
            nothing                   
        )
    )
end

function make_multiply_const_function(constant::Real)
    return function add_const_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        result = data[!, source[1]] .* constant
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                result,        # get the column out of the dataframe
                identity,      # apply generic_fn to it
                nothing,            
                nothing                   
            )
        )
    end
end

Base.:*(s1::Symbol, s2::Symbol) = [s1, s2] => AesTransform(multiply_cols_fn)
Base.:*(s1::Symbol, s2::Real) = [s1] => AesTransform(make_multiply_const_function(s2))
Base.:*(s2::Real, s1::Symbol) = [s1] => AesTransform(make_multiply_const_function(s2))


import Base.:/

function divide_cols_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    result = data[!, source[1]] ./ data[!, source[2]]
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            result,        
            identity,                
            nothing,            
            nothing                   
        )
    )
end

function make_divide_const_function(constant::Real)
    return function add_const_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        result = constant ./ data[!, source[1]]
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                result,        # get the column out of the dataframe
                identity,      # apply generic_fn to it
                nothing,            
                nothing                   
            )
        )
    end
end

Base.:/(s1::Symbol, s2::Symbol) = [s1, s2] => AesTransform(divide_cols_fn)
Base.:/(s1::Symbol, s2::Real) = [s1] => AesTransform(make_multiply_const_function(1/s2))
Base.:/(s2::Real, s1::Symbol) = [s1] => AesTransform(make_divide_const_function(s2))
