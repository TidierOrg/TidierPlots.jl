function colour_scale_to_ggoptions(args_dict::Dict)
    function color_transform_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        input = data[!, source[1]]
        colors = parse.(Colorant, args_dict[:values]) # parse the input as colors

        if typeof(input) <: Union{AbstractString, AbstractChar, CategoricalArray}
            
            cat_array = CategoricalArray(input)

            return Dict{Symbol, PlottableData}(
                target => PlottableData(
                    cat_array,
                    x -> colors[levelcode.(x)],
                    nothing,
                    nothing
                )
            )     
        elseif typeof(input) <: Int
            return Dict{Symbol, PlottableData}(
                target => PlottableData(
                    input,
                    x -> colors[x],
                    nothing,
                    nothing
                )
            ) 
        else # try to parse whatever it is as an int
            try
                int_array = floor.(Int, input)
            catch
                scale = args_dict[:scale]
                @error "Column is not compatible with scale: $scale"
            end

            return Dict{Symbol, PlottableData}(
                target => PlottableData(
                    int_array,
                    x -> colors[x],
                    nothing,
                    nothing
                )
            )
        end          
    end
    
    color_transform = AesTransform(color_transform_fn)
    
    return AxisOptions(
        Dict(), 
        Dict(args_dict[:scale] => args_dict[:scale]=>color_transform)
    )
end

function colour_scale_template(scale, f)
    function scale_function(args...; scale = scale, f = f, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; scale = scale, f = f, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return plot + f(args_dict)
    end
    return scale_function
end


scale_colour_manual = colour_scale_template(:color, colour_scale_to_ggoptions)
scale_color_manual =  colour_scale_template(:color, colour_scale_to_ggoptions)