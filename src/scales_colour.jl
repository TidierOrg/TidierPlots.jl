function make_color_lookup_manual(args_dict)
    function color_lookup_manual(input)
        colors = parse.(Colorant, args_dict[:values]) 
        return colors[input]
    end
    return color_lookup_manual
end

function make_color_lookup_discrete(args_dict)
    function color_lookup_discrete(input)
        palette = haskey(args_dict, :palette) ? args_dict[:palette] : 
            haskey(args_dict, :values) ? args_dict[:values][1] : nothing
    
        if isnothing(palette)
            @error "Invalid palette specification in discrete color scale."
        end

        scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
                palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
                palette isa ColorScheme ? palette : nothing

        if isnothing(scheme)
            palette_type = typeof(palette)
            @error "Palette should be a String, a Symbol, or a ColorScheme, not a $palette_type"
        end

        return scheme[input]
    end
    return color_lookup_discrete
end

function make_color_lookup_continuous(args_dict)
    function color_lookup_continuous(input)
        scaled_input = input ./ maximum(input)
    
        palette = haskey(args_dict, :palette) ? args_dict[:palette] : 
            haskey(args_dict, :values) ? args_dict[:values][1] : nothing
    
        if isnothing(palette)
            @error "Invalid palette specification in continuous color scale."
        end

        scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

        if isnothing(scheme)
            palette_type = typeof(palette)
            @error "Palette should be a String, a Symbol, or a ColorScheme, not a $palette_type"
        end
    
        return get(scheme, scaled_input)
    end
    return color_lookup_continuous
end

function make_color_lookup_binned(args_dict)
    function color_lookup_binned(input)
        binned_input = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))
    
        palette = haskey(args_dict, :palette) ? args_dict[:palette] : 
            haskey(args_dict, :values) ? args_dict[:values][1] : nothing
    
        if isnothing(palette)
            @error "Invalid palette specification in binned color scale."
        end

        scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

        if isnothing(scheme)
            palette_type = typeof(palette)
            @error "Palette should be a String, a Symbol, or a ColorScheme, not a $palette_type"
        end
    
        return scheme[binned_input]
    end
    return color_lookup_binned
end

function color_scale_to_ggoptions(args_dict::Dict)

    lookup = args_dict[:type] == "manual"     ? make_color_lookup_manual(args_dict)     : 
             args_dict[:type] == "discrete"   ? make_color_lookup_discrete(args_dict)   : 
             args_dict[:type] == "continuous" ? make_color_lookup_continuous(args_dict) :
             make_color_lookup_binned(args_dict)
    
    function make_color_transform_fn(lookup)
        function color_transform_fn(target::Symbol, source::Vector{Symbol}, data::DataFrame)
            input = data[!, source[1]]

            if typeof(input) <: Union{AbstractVector{String}, AbstractVector{Char}, CategoricalArray}
            
                cat_array = CategoricalArray(input)

                return Dict{Symbol, PlottableData}(
                    target => PlottableData(
                        cat_array,
                        x -> lookup(levelcode.(x)),
                        nothing,
                        nothing
                    )
                )     
            elseif typeof(input) <: Union{Vector{Int}, Vector{Float64}, Vector{Float32}}
                return Dict{Symbol, PlottableData}(
                    target => PlottableData(
                        input,
                        x -> lookup(x),
                        nothing,
                        nothing
                    )
                ) 
            else # try to parse whatever it is as an int, error if not successful
                try
                    int_array = parse.(Int, input)
                catch
                    scale = args_dict[:scale]
                    @error "Column is not compatible with scale: $scale"
                end

                return Dict{Symbol, PlottableData}(
                    target => PlottableData(
                        int_array,
                        x -> lookup(x),
                        nothing,
                        nothing
                    )
                )
            end          
        end
        return color_transform_fn
    end
    
    color_transform = AesTransform(make_color_transform_fn(lookup))
    
    return AxisOptions(
        Dict(), 
        Dict(Symbol(args_dict[:scale]) => [Symbol(args_dict[:scale])]=>color_transform)
    )
end

function color_scale_template(scale, f, type)
    function scale_function(args...; scale = scale, f = f, type = type, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        args_dict[:type] = type
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; scale = scale, f = f, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        args_dict[:type] = type
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return plot + f(args_dict)
    end
    return scale_function
end

# scale definitions

#scale_colour_manual =     color_scale_template("color", color_scale_to_ggoptions, "manual")
scale_color_manual =      color_scale_template("color", color_scale_to_ggoptions, "manual")
#scale_colour_discrete =   color_scale_template("color", color_scale_to_ggoptions, "discrete")
scale_color_discrete =    color_scale_template("color", color_scale_to_ggoptions, "discrete")
#scale_colour_continuous = color_scale_template("color", color_scale_to_ggoptions, "continuous")
scale_color_continuous =  color_scale_template("color", color_scale_to_ggoptions, "continuous")
#scale_colour_binned =     color_scale_template("color", color_scale_to_ggoptions, "binned")
scale_color_binned =      color_scale_template("color", color_scale_to_ggoptions, "binned")