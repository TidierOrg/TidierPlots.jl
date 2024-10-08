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
        input = convert.(Float64, input)

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

    lookup = args_dict[:type] == "manual"       ?
        make_color_lookup_manual(args_dict)     :
        args_dict[:type] == "discrete"          ?
        make_color_lookup_discrete(args_dict)   :
        args_dict[:type] == "continuous"        ?
        make_color_lookup_continuous(args_dict) :
        make_color_lookup_binned(args_dict)

    if args_dict[:scale] == "color"
        color = lookup
        fill = nothing
    elseif args_dict[:scale] == "fill"
        color = nothing
        fill = lookup
    else
        throw("Unrecognized scale: $(args_dict[:scale])")
    end

    return AxisOptions(
        Dict(),
        color,
        fill,
        Dict(:color => args_dict) # pass the full args dict for use by legend
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

# default palettes

const _default_discrete_palette = make_color_lookup_manual(
    Dict(:values => [
        RGB(0/255, 114/255, 178/255), # blue
        RGB(230/255, 159/255, 0/255), # orange
        RGB(0/255, 158/255, 115/255), # green
        RGB(204/255, 121/255, 167/255), # reddish purple
        RGB(86/255, 180/255, 233/255), # sky blue
        RGB(213/255, 94/255, 0/255), # vermillion
        RGB(240/255, 228/255, 66/255), # yellow
    ])
)
const _default_continuous_palette = make_color_lookup_continuous(
    :palette => :viridis
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
