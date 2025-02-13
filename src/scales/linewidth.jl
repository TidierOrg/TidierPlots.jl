"""
Internal function. Takes a Dict and makes a function that maps a numeric vector to the range specfied in the Dict's :range key, or to [0.1, 1.0] if not specified.
"""
function make_linewidth_lookup_continuous(args_dict::Dict)
    r = get(args_dict, :range, [1, 5])

    function linewidth_lookup_continuous(input)
        return r[1] .+ (r[2] - r[1]) .* (input ./ maximum(input))
    end
    return linewidth_lookup_continuous
end

"""
Internal function. Converts args_dict to AxisOptions.
"""
function linewidth_scale_to_ggoptions(args_dict::Dict)
    palette = Dict{Symbol,Function}()
    palette[:linewidth] = make_linewidth_lookup_continuous(args_dict)

    return AxisOptions(
        Dict(),
        palette,
        Dict(:linewidth => args_dict)
    )
end

scale_linewidth = color_scale_template(
    "linewidth",
    linewidth_scale_to_ggoptions,
    "continuous"
)
