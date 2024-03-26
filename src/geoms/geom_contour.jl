function stat_density_2d(aes_dict::Dict{String, Symbol}, 
    args_dict, required_aes::Vector{String}, plot_data::DataFrame)

    x = plot_data[!, aes_dict["x"]]
    y = plot_data[!, aes_dict["y"]]

    k = kde((x, y))

    required_aes = ["z"]

    aes_dict["z"] = :z
    delete!(aes_dict, "x")
    delete!(aes_dict, "y")

    return_data = Dict(:z => k.density)

    return (aes_dict, args_dict, required_aes, return_data)
end

geom_tile = geom_template("geom_tile", ["x", "y", "z"], :Heatmap)
geom_contour = geom_template("geom_contour", ["x", "y"], :Contour; aes_function = stat_density_2d)
