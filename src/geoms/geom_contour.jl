function stat_density_2d(aes_dict::Dict{String, Symbol},
    args_dict, required_aes::Vector{String}, plot_data::DataFrame)

    new_required_aes = ["x", "y", "z"]

    aes_dict["z"] = :z

    return (aes_dict, args_dict, new_required_aes, plot_data)
end

"""
    geom_tile(aes(...), ...)
    geom_tile(plot::GGPlot, aes(...), ...)

Represents data as...

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Heatmap)

# Required Aesthetics

TBD

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
geom_tile = geom_template("geom_tile", ["x", "y", "z"], :Heatmap)

"""
    geom_contour(aes(...), ...)
    geom_contour(plot::GGPlot, aes(...), ...)

Represents a grid of data as smooth curves of a surface.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Contour)

# Required Aesthetics

TBD

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
geom_contour = geom_template("geom_contour", ["x", "y"], :Contour;
    aes_function = stat_density_2d,
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(
        :x => [:x]=>discard,
        :y => [:y]=>discard,
        :z => [:x, :y]=>kernel_density_2d))
