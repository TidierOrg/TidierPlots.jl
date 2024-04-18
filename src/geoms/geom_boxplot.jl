function boxplot_groups(aes_dict::Dict{String, Symbol},
    args_dict::Dict{Any, Any}, required_aes::Vector{String}, plot_data::DataFrame)

    factor_aes = [aes for (aes, v) in aes_dict if eltype(plot_data[!, v]) <: Union{AbstractString, AbstractChar, CategoricalValue}]
        
    if "y" in factor_aes && !("x" in factor_aes)
        aes_dict["x"], aes_dict["y"] = aes_dict["y"], aes_dict["x"] # swap
        args_dict["orientation"] = :horizontal
    end

    dodge_aes = [aes for aes in factor_aes if aes_dict[aes] != aes_dict["x"]]

    println(dodge_aes)

    if length(dodge_aes) > 1
        @warn "Too many categorical aes specified"
    end

    if length(dodge_aes) != 0
        aes_dict["dodge"] = aes_dict[dodge_aes[1]]
    end

    return  (aes_dict, args_dict, required_aes, plot_data)
end

"""
    geom_boxplot(aes(...), ...)
    geom_boxplot(plot::GGPlot, aes(...), ...)

Compactly displays the distribution of continuous data.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.BoxPlot)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

- colour/color

# Supported Options

TBD
"""
geom_boxplot = geom_template("geom_boxplot", ["x", "y"], :BoxPlot; aes_function = boxplot_groups)
