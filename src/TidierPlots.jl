module TidierPlots

using Makie
using CairoMakie
using AlgebraOfGraphics
using DataFrames

include("structs.jl")
include("geoms.jl")

export draw_ggplot, geom_to_layer, ggplot_to_layers, @ggplot
export @geom_point, @geom_smooth, @geom_bar

const autoplot = Ref{Bool}(true)

function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "autoplot"
       autoplot[] = value
    else
      throw("That is not a valid option.")
    end
end

function Base.:+(x::ggplot, y...)::ggplot
    result = ggplot(vcat(x.geoms, [i for i in y if i isa geom]), 
        x.default_aes, 
        x.data, 
        x.axis)

    # don't tell the julia police
    if autoplot[]
        display(draw_ggplot(result))
    end

    return result
end

macro ggplot(exprs...)
    aes_dict, args_dict = extract_aes(:($(exprs)))

    haskey(args_dict, "height") ?
        height = args_dict["height"] :
        height = 400

    haskey(args_dict, "width") ?
        width = args_dict["width"] :
        width = 600

    haskey(args_dict, "data") ? 
        plot_data = args_dict["data"] :
        plot_data = nothing
    
    ggplot([], aes_dict, 
            AlgebraOfGraphics.data(Base.eval(Main, plot_data)),
            (height = height, width = width)) 
end

function extract_aes(geom)
    aes_dict = Dict{String, Symbol}() 
    args_dict = Dict{String, Any}() 

    for section in geom
        if section isa Expr
            # if the section is an expression, check if it is a aes function call
            if section.args[1] == :aes
                for aes_ex in section.args
                    if aes_ex isa Expr
                        aes_dict[String(aes_ex.args[1])] = aes_ex.args[2]
                    end
                end
            # if not, its a generic argument
            else
                args_dict[String(section.args[1])] = section.args[2]
            end
        end
    end

    return (aes_dict, args_dict)
end

function check_aes(required_aes, aes_dict)
    for aes in required_aes
        if !haskey(aes_dict, aes)
            error("missing required aesthetic: $aes")
        end
    end
end

function geom_to_layer(geom)
    if isnothing(geom.data)
        error("no data available for geom")
    else
        return geom_to_layer(geom, geom.data)
    end
end 

function geom_to_layer(geom, data)
    
    check_aes(geom.required_aes, geom.aes)

    mapping_args = (geom.aes[key] for key in geom.required_aes)

    # check which supported optional aesthetics are available

    available_optional_aes = intersect(
        keys(geom.aes),
        keys(geom.optional_aes)
    )

    # if any are available, multiply them in to the layer 
    # geom.optional_aes[a] gets the expected AoG arg name
    # geom_aes[a] gets the variable that was assigned to the aesthetic
    # if none are available, just use the required aes

    if length(available_optional_aes) != 0
        optional_mapping_args = Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] for a in available_optional_aes)
        layer = data * mapping(mapping_args...; optional_mapping_args...)
    else
        layer = data * mapping(mapping_args...)
    end    

    if !isnothing(geom.analysis)
        layer = layer * (geom.analysis)()
    end

    if !isnothing(geom.visual)
        layer = layer * geom.visual
    end

    return layer
end

function draw_ggplot(plot::ggplot)
    layers = []
    
    for geom in plot.geoms
        # if data is not specified at the geom level, use the ggplot default
        if isnothing(geom.data)
            data = plot.data
        else 
            data = geom.data
        end

        # if an aes isn't given in the geom, use the ggplot aes
        for aes in keys(plot.default_aes)
            if !haskey(geom.aes, aes)
                geom.aes[aes] = plot.default_aes[aes]
            end
        end

        push!(layers, geom_to_layer(geom, data))
    end

    if length(layers) == 0
        error("No geoms supplied")
    elseif length(layers) == 1
        draw(layers[1]; axis = plot.axis)
    else 
        draw((+)(layers...); axis = plot.axis)
    end
end

end

