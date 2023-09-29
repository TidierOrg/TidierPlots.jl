geom_line = geom_template("geom_line", ["x", "y"], Makie.Lines, mapping())
geom_step = geom_template("geom_step", ["x", "y"], Makie.Stairs, mapping())
geom_path = geom_template("geom_path", ["x", "y"], Makie.Lines, mapping())