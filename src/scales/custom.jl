"""
    scale_custom(aes, function, legend_options = Dict())
    scale_custom(plot, aes, function, legend_options = Dict())

Create a custom scale for any aes.

# Arguments

- `plot`: Optional. GGPlot to apply this scale to
- `aes`: The aes that the scale is for
- `function`: Function to apply to the raw data. Should accept one argument (vector of data as it appears in your DataFrame) and return a vector in the format expected by Makie.
- `legend_options`: Used to generate the guides for the plot
"""
function scale_custom(aes, function, legend_options = Dict())
    return AxisOptions(
        Dict(),
        Dict(Symbol(aes) => function),
        legend_options
    )
end

function scale_custom(plot::GGPlot, aes, function, legend_options = Dict())
    return plot + scale_custom(aes, function, legend_options)
end
