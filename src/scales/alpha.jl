"""
Internal function. Takes a Dict and makes a function that maps a numeric vector to the range specfied in the Dict's :range key, or to [0.1, 1.0] if not specified.
"""
function make_alpha_lookup_continuous(args_dict::Dict)
    r = get(args_dict, :range, [0.1, 1])

    function alpha_lookup_continuous(input)
        return r[1] .+ (r[2] - r[1]) .* (input ./ maximum(input))
    end
    return alpha_lookup_continuous
end

"""
Internal function. Converts args_dict to AxisOptions.
"""
function alpha_scale_to_ggoptions(args_dict::Dict)
    palette = Dict{Symbol,Function}()
    palette[:alpha] = make_alpha_lookup_continuous(args_dict)

    return AxisOptions(
        Dict(),
        palette,
        Dict(:alpha => args_dict) # pass the full args dict for use by legend
    )
end
