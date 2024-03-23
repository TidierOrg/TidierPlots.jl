"""
    geom_smooth(aes(...), ...)
    geom_smooth(plot::GGPlot, aes(...), ...)
    
    Represent data as a smoothed or linear fit. 

    # Arguments

    - `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
    - `...`: options that are not mapped to a column 

    # Required Aesthetics

    - x
    - y

    # Supported Optional Aesthetics

    - alpha
    - colour/color

    # Supported Options

    - method: "smooth" (loess fit) or "lm" (linear fit)
    - alpha
    - colour/color

"""
function geom_smooth(plot::GGPlot, args...; kwargs...)
    return plot + geom_smooth(args...; kwargs...)
end

function geom_smooth(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    args_dict["geom_name"] = "geom_smooth"
    
    analysis = stat_loess

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = stat_linear
        end
    end
    
    # geom_smooth returns TWO makie plots: 
    # :Lines - the center line
    # :Band - the uncertainty interval

    return [build_geom(aes_dict, 
                      args_dict, 
                      ["x", "y"],
                      :Lines, 
                      analysis),
            build_geom(aes_dict,
                      args_dict, 
                      ["x", "lower", "upper"],
                      :Band, 
                      analysis)]
end

function stat_loess(aes_dict::Dict{String, Symbol}, 
    args_dict::Dict{Any, Any}, required_aes::Vector{String}, plot_data::DataFrame)

    return (aes_dict, args_dict, required_aes, plot_data)
end

function stat_linear(aes_dict::Dict{String, Symbol}, 
    args_dict::Dict{String, Any}, required_aes::Vector{String}, plot_data::DataFrame)

    x = plot_data[!, aes_dict["x"]]
    y = plot_data[!, aes_dict["y"]]

    # thanks AlgebraOfGraphics
    function add_intercept_column(x::AbstractVector{T}) where {T}
        mat = similar(x, float(T), (length(x), 2))
        fill!(view(mat, :, 1), 1)
        copyto!(view(mat, :, 2), x)
        return mat
    end

    lin_model = GLM.lm(add_intercept_column(x), y)
    x̂ = range(extrema(x)..., length = 100)
    pred = DataFrame(GLM.predict(lin_model, add_intercept_column(x̂); interval = :confidence))
    
    aes_dict["upper"] = :upper
    aes_dict["lower"] = :lower

    return_data = DataFrame(
        String(aes_dict["x"]) => x̂,
        String(aes_dict["y"]) => pred.prediction,
        "lower" => pred.lower,
        "upper" => pred.upper
    )

    return (aes_dict, args_dict, required_aes, return_data)
end