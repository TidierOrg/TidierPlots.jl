"""
Internal function. Converts args_dict to AxisOptions.
"""
function shape_scale_to_ggoptions(args_dict::Dict)
    palette = Dict{Symbol,Function}()

    shape_list = [
        :circle,
        :cross,
        :utriangle,
        :rect,
        :pentagon,
        :hexagon
    ]

    if length(args_dict[:values]) > 0
        shape_list = args_dict[:values]
    end

    function shape_lookup_discrete(input)
        if length(unique(input)) > length(unique(shape_list))
            throw(ArgumentError("Too many unique values for shape scale. Choose a different scale or increase the number of shapes. ($(length(unique(input))) values, $(length(unique(shape_list))) shapes available)"))
        end

        input_as_int = levelcode.(CategoricalArray(input))

        return shape_list[input_as_int]
    end

    palette[:marker] = shape_lookup_discrete

    return AxisOptions(
        Dict(),
        palette,
        Dict(:marker => merge(Dict(:guide => :legend), args_dict))
    )
end

scale_shape = color_scale_template(
    "shape",
    shape_scale_to_ggoptions,
    "discrete"
)

scale_shape_discrete = color_scale_template(
    "shape",
    shape_scale_to_ggoptions,
    "discrete"
)
