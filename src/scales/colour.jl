function make_color_lookup_manual(args_dict::Dict)
    colors = eltype(args_dict[:values]) <: Colorant ?
             args_dict[:values] :
             parse.(Colors.RGBA, args_dict[:values])

    function color_lookup_manual(input::T) where {T <: Union{Colorant,Vector{Colorant}}}
        return input
    end
    function color_lookup_manual(input::Any)
        return [colors[x] for x in levelcode.(CategoricalArray(input))]
    end
    function color_lookup_manual(input::CategoricalArray)
        return [colors[levelcode(x)] for x in input]
    end
    function color_lookup_manual(input::Integer)
        return [colors[x] for x in input]
    end
    return color_lookup_manual
end

function make_color_lookup_discrete(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in discrete color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $(typeof(palette))"))
    end

    function color_lookup_discrete(input::Any)
        return scheme[levelcode.(CategoricalArray(input))]
    end
    function color_lookup_discrete(input::CategoricalArray)
        return scheme[levelcode.(input)]
    end
    function color_lookup_discrete(input::Integer)
        return scheme[input]
    end
    function color_lookup_discrete(input::AbstractFloat)
        return scheme[round.(Integer, input)]
    end

    return color_lookup_discrete
end

function make_color_lookup_continuous(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in continuous color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $(typeof(palette))"))
    end

    function color_lookup_continuous(input)
        return get(scheme, input ./ maximum(input))
    end
    return color_lookup_continuous
end

function make_color_lookup_binned(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in binned color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        palette_type = typeof(palette)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $palette_type"))
    end

    function color_lookup_binned(input)
        input = convert.(Float64, input)

        binned_input = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))

        return scheme[binned_input]
    end
    return color_lookup_binned
end

function color_scale_to_ggoptions(args_dict::Dict)

    lookup = args_dict[:type] == "manual" ?
             make_color_lookup_manual(args_dict) :
             args_dict[:type] == "discrete" ?
             make_color_lookup_discrete(args_dict) :
             args_dict[:type] == "continuous" ?
             make_color_lookup_continuous(args_dict) :
             make_color_lookup_binned(args_dict)

    palette = Dict()

    args_dict[:guide] = args_dict[:type] in ["manual", "discrete"] ?
                        :legend : :colorbar

    if args_dict[:scale] == "color"
        palette[:color] = lookup
    elseif args_dict[:scale] == "fill"
        palette[:fill] = lookup
    else
        throw(ArgumentError("Unrecognized scale: $(args_dict[:scale])"))
    end

    return AxisOptions(
        Dict(),
        palette,
        Dict(:color => args_dict) # pass the full args dict for use by legend
    )
end

function color_scale_template(scale, f, type)
    function scale_function(args...; scale=scale, f=f, type=type, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        args_dict[:type] = type
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; scale=scale, f=f, kwargs...)
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

# default palettes

const _default_discrete_palette = make_color_lookup_manual(
    Dict(:values => [
        RGB(0 / 255, 114 / 255, 178 / 255), # blue
        RGB(230 / 255, 159 / 255, 0 / 255), # orange
        RGB(0 / 255, 158 / 255, 115 / 255), # green
        RGB(204 / 255, 121 / 255, 167 / 255), # reddish purple
        RGB(86 / 255, 180 / 255, 233 / 255), # sky blue
        RGB(213 / 255, 94 / 255, 0 / 255), # vermillion
        RGB(240 / 255, 228 / 255, 66 / 255), # yellow
    ])
)
const _default_continuous_palette = make_color_lookup_continuous(
    Dict(:palette => :viridis)
)

# scale definitions

scale_colour_manual = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "manual")

scale_color_manual = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "manual")

scale_colour_discrete = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "discrete")

scale_color_discrete = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "discrete")

scale_colour_continuous = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "continuous")

scale_color_continuous = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "continuous")

scale_colour_binned = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "binned")

scale_color_binned = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "binned")

scale_fill_manual = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "manual")

scale_fill_discrete = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "discrete")

scale_fill_continuous = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "continuous")

scale_colour_binned = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "binned")

scale_alpha_continuous = color_scale_template(
    "alpha",
    alpha_scale_to_ggoptions,
    "continuous"
)

scale_alpha = color_scale_template(
    "alpha",
    alpha_scale_to_ggoptions,
    "continuous"
)
