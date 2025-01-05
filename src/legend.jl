"""
Sets which scales will get legends or colorbars. Use the name of the scale and either the string "legend" or "colorbar" to add a guide.
"""
function guides(args...; kwargs...)
    return AxisOptions(
        Dict{Symbol,Any}(),
        Dict(),
        Dict(k => Dict(:guide => Symbol(v)) for (k, v) in Dict(kwargs))
    )
end
