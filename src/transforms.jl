# transformation functions for aes specification
# they all should return a Dict that maps an aes symbol
# to a PlottableData struct which contains

# - raw: the data
# - makie_function: what should be done before data goes to the Makie arg
# - label_target: where should the labels go? 
# - label_function: what should be done to data in "position" to display it

struct PlottableData
    raw::Any
    makie_function::Function
    label_target::Union{Symbol, Nothing}
    label_function::Any
end

# simplest one is as_is, which just gets a column 
# exactly as it is in the DataFrame

function as_is(target::Symbol, data::DataFrame)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            data[!, target],           # get the column out of the dataframe
            identity,                  # do nothing to it
            nothing,            
            nothing                   
        )
    )
end

# verbatim has a similar goal, but for String columns

function convert_to(type::Type)
    return function(target::Symbol, data::DataFrame)
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                type.(data[!, target]),
                identity,
                nothing,
                nothing
            )
        )
    end
end

verbatim = convert_to(String)

function number_on_axis(target::Symbol, data::DataFrame)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            data[!, target],                    # get the column out of the dataframe
            identity,                           # do nothing to it
            Symbol(String(target) * "ticks"),   # the axis label it will have, e.g. :xticks
            Makie.automatic                     # calculate those ticks automatically
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
            cat_array,
            x -> levelcode.(x),
            Symbol(String(target) * "ticks"),
            x -> (1:length(levels(x)), levels(x))
        )
    )    
end

function cat_inseq(target::Symbol, data::DataFrame)
    cat_array = CategoricalArray(data[!, target])
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            cat_array,
            x -> levelcode.(x),
            Symbol(String(target) * "ticks"),
            x -> (1:length(levels(x)), levels(x))
        )
    )      
end

# kernel density estimation for geom_contour

function kernel_density_2d(x::Symbol, y::Symbol, data::DataFrame)

    k = kde((data[!, x], data[!, y]))

    return Dict{Symbol, PlottableData}(
        :x => PlottableData(k.x, identity, 
            :xticks,
            Makie.automatic),
        :y => PlottableData(k.y, identity, 
            :yticks,
            Makie.automatic),
        :z => PlottableData(k.density, identity, 
            :zticks,
            Makie.automatic)
    )
end
