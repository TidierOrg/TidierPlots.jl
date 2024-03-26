# transformation functions for aes specification
# they all should return a Dict that maps a aes symbol
# to a PlottableData struct which contains

# - position: the data
# - label_target: where should the labels go? 
# - label_function: what should be done to data in "position" to display it
# - makie_function: what should be done before data goes to the Makie arg

struct PlottableData
    position::Any
    makie_function::Function
    label_target::Union{Symbol, Nothing}
    label_function::Any
end

# simplest one is as_is, which just gets the column 
# exactly as it is in the DataFrame

function as_is(target::Symbol, data::DataFrame)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(data[!, target],
            identity,
            Symbol(String(target) * "ticks"),
            Makie.automatic
        )
    )
end

# categorical array handling options for String columns

function cat_inorder(target::Symbol, data::DataFrame)
    cat_column = data[!, target]
    cat_array = CategoricalArray(cat_column,
        levels = unique(cat_column),
        ordered = true)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            levelcode.(cat_array),
            x -> levels(x)
        )
    )    
end

function cat_inseq(target::Symbol, data::DataFrame)
    cat_array = CategoricalArray(data[!, target])
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            levelcode.(cat_array),
            x -> levels(x)
        )
    )      
end

# kernel density estimation for geom_contour

function kernel_density_2d(x::Symbol, y::Symbol, data::DataFrame)

    k = kde((data[!, x], data[!, y]))

    return Dict{Symbol, PlottableData}(
        :x => PlottableData(k.x, identity),
        :y => PlottableData(k.y, identity),
        :z => PlottableData(k.density, identity)
    )
end
