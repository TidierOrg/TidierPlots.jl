geom_text = geom_template("geom_text", ["x", "y"], :Text; 
    column_transformations = Dict{Symbol, Function}(:text => verbatim))
geom_label = geom_template("geom_label", ["x", "y"], :Text; 
    column_transformations = Dict{Symbol, Function}(:text => verbatim))