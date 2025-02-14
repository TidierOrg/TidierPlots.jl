"""
Internal function. Converts args_dict to AxisOptions.
"""
function size_scale_to_ggoptions(args_dict::Dict)
    palette = Dict{Symbol,Function}()
    r = get(args_dict, :range, [1, 5])

    function size_lookup_continuous(input)
        return r[1] .+ (r[2] - r[1]) .*
                       ((input .- minimum(input)) ./ maximum(input))
    end

    palette[:markersize] = size_lookup_continuous

    return AxisOptions(
        Dict(),
        palette,
        Dict(:markersize => merge(Dict(:guide => :legend_size), args_dict))
    )
end

scale_size = color_scale_template(
    "size",
    size_scale_to_ggoptions,
    "continuous"
)
