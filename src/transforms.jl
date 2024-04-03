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

function as_is(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            data[!, source[1]],           # get the column out of the dataframe
            identity,                  # do nothing to it
            nothing,            
            nothing                   
        )
    )
end

# verbatim has a similar goal, but for String columns

function convert_to(type::Type)
    return function(target::Symbol, source::Vector{Symbol}, data::DataFrame)
        return Dict{Symbol, PlottableData}(
            target => PlottableData(
                type.(data[!, source[1]]),
                identity,
                nothing,
                nothing
            )
        )
    end
end

verbatim = convert_to(String)

function number_on_axis(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            data[!, source[1]],                 # get the column out of the dataframe
            identity,                           # do nothing to it
            Symbol(String(target) * "ticks"),   # the axis label it will have, e.g. :xticks
            Makie.automatic                     # calculate those ticks automatically
        )
    )
end



# categorical array handling options for String columns

function cat_inorder(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    cat_column = data[!, source[1]]
    cat_array = CategoricalArray(cat_column,
        levels = unique(cat_column),
        ordered = true)
    
    label_target = target == :x ? :xticks :
                   target == :y ? :yticks : 
                   nothing
    
    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            cat_array,
            x -> levelcode.(x),
            label_target,
            x -> (1:length(levels(x)), levels(x))
        )
    )    
end

function cat_inseq(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    cat_array = CategoricalArray(data[!, source[1]])

    label_target = target == :x ? :xticks :
                   target == :y ? :yticks : 
                   nothing

    return Dict{Symbol, PlottableData}(
        target => PlottableData(
            cat_array,
            x -> levelcode.(x),
            label_target,
            x -> (1:length(levels(x)), levels(x))
        )
    )      
end

# kernel density estimation for geom_contour

function kernel_density_2d(target::Symbol, source::Vector{Symbol}, data::DataFrame)

    k = kde((data[!, source[1]], data[!, source[2]]))

    return_dict = Dict{Symbol, PlottableData}(
        :x => PlottableData(k.x, identity, nothing, nothing),
        :y => PlottableData(k.y, identity, nothing, nothing),
        :z => PlottableData(k.density, 
            identity, 
            nothing,
            nothing)
    )

    return return_dict
end

# returns nothing, removing aes from graph

function discard(target::Symbol, source::Vector{Symbol}, data::DataFrame)
    return Dict{Symbol, PlottableData}()
end

# tweaks
# takes an existing PlottableData object and modifies the makie_function

function as_color(plottable_data_object::PlottableData)
    colors = [
               RGB(0/255, 114/255, 178/255), # blue
               RGB(230/255, 159/255, 0/255), # orange
               RGB(0/255, 158/255, 115/255), # green
               RGB(204/255, 121/255, 167/255), # reddish purple
               RGB(86/255, 180/255, 233/255), # sky blue
               RGB(213/255, 94/255, 0/255), # vermillion
               RGB(240/255, 228/255, 66/255), # yellow
    ]

    return PlottableData(
        plottable_data_object.raw,
        (x -> colors[x]) ∘ plottable_data_object.makie_function,
        plottable_data_object.label_target,
        plottable_data_object.label_function
    )
end
