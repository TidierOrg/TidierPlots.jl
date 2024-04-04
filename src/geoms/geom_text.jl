geom_text = geom_template("geom_text", ["x", "y"], :Text; 
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(:text => [:text]=>verbatim))
geom_label = geom_template("geom_label", ["x", "y"], :Text; 
    column_transformations = Dict{Symbol, Pair{Vector{Symbol}, AesTransform}}(:text => [:text]=>verbatim))