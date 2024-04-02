function stat_density_2d(aes_dict::Dict{String, Symbol}, 
    args_dict, required_aes::Vector{String}, plot_data::DataFrame)

    new_required_aes = ["z"]

    return (aes_dict, args_dict, new_required_aes, plot_data)
end

geom_tile = geom_template("geom_tile", ["x", "y", "z"], :Heatmap)
geom_contour = geom_template("geom_contour", ["x", "y"], :Contour; 
    aes_function = stat_density_2d,
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, Function}}(:z => [:x, :y] => kernel_density_2d))
