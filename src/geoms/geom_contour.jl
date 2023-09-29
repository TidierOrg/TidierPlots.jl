geom_tile = geom_template("geom_tile", ["x", "y"], Makie.Heatmap, AlgebraOfGraphics.density())
geom_contour = geom_template("geom_contour", ["x", "y"], Makie.Contour, AlgebraOfGraphics.density())