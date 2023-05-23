module TidierPlots

using Makie
using CairoMakie
using AlgebraOfGraphics
using DataFrames
using Reexport

include("structs.jl")
include("geom_bar.jl")
include("geom_point.jl")
include("geom_smooth.jl")
include("labs.jl")
include("scales.jl")

@reexport using Makie: theme_black, theme_dark, theme_ggplot2, theme_light, theme_minimal

export draw_ggplot, geom_to_layer, ggplot_to_layers, layer_equal, @ggplot
export @geom_point, @geom_smooth, @geom_bar
export @labs, @lims
export @scale_x_continuous, @scale_y_continuous, @scale_x_log10, @scale_y_log10
export @scale_x_reverse, @scale_y_reverse, @scale_x_sqrt, @scale_y_sqrt

const autoplot = Ref{Bool}(true)

function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "autoplot"
       autoplot[] = value
    else
      throw("That is not a valid option.")
    end
end

function Base.:+(x::GGPlot, y...)::GGPlot
    result = GGPlot(vcat(x.geoms, [i for i in y if i isa Geom]), 
        x.default_aes, 
        x.data,
        GGOptions(merge(x.labs.values, [l.values for l in y if l isa GGOptions]...)), 
        x.axis)

    theme = [t for t in y if t isa Attributes]

    if length(theme) == 0
        theme = Makie.theme_ggplot2()
    else
        theme = theme[end]
    end

    # don't tell the julia police
    if autoplot[]
        with_theme(theme) do
            display(draw_ggplot(result))
        end
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
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = mapping()
    
    GGPlot([], aes_dict, 
            plot_data,
            GGOptions(Dict()), 
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
                        if aes_ex.args[2] isa QuoteNode
                            aes_dict[String(aes_ex.args[1])] = aes_ex.args[2].value
                        else
                            aes_dict[String(aes_ex.args[1])] = aes_ex.args[2] 
                        end
                    end
                end
            # if not, its a generic argument
            else
                if section.args[2] isa QuoteNode
                    args_dict[String(section.args[1])] = section.args[2].value
                else 
                    args_dict[String(section.args[1])] = section.args[2]
                end
            end
        elseif section isa Symbol
            # if the section is a symbol, assume it is meant to be the data argument
            args_dict["data"] = section
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

function layer_equal(L1::Layer, L2::Layer)
    if L1.transformation != L2.transformation
        return false
    elseif L1.data != L2.data
        return false
    elseif L1.named != L2.named
        return false
    elseif L1.positional != L2.positional
        return false
    else
        return true
    end
end

function geom_to_layer(geom, data, labs)
    
    check_aes(geom.required_aes, geom.aes)

    mapping_args_array = []

    # rename required aes if labs are given
    # this section is possibly not required with the current geoms
    # as x and y will be renamed elsewhere
    # it is retained in case geoms with required aes other than ["x", "y"]
    # are implemented 

    for key in geom.required_aes
        if !haskey(labs.values, key)
            push!(mapping_args_array, Symbol(geom.aes[key]))
        else 
            push!(mapping_args_array, Symbol(geom.aes[key]) => labs.values[key])
        end
    end
    
    mapping_args = Tuple(mapping_args_array)

    # check which supported optional aesthetics are available
    # and which ones have labels assigned to them

    available_optional_aes = intersect(
        keys(geom.aes),
        keys(geom.optional_aes)
    )

    labelled_optional_aes = intersect(
        keys(labs.values),
        available_optional_aes
    )

    unlabelled_optional_aes = symdiff(
        labelled_optional_aes, 
        available_optional_aes
    )

    # if any are available, multiply them in to the layer 
    # geom.optional_aes[a] gets the expected AoG arg name
    # geom_aes[a] gets the variable that was assigned to the aesthetic
    # if applicable, labs.values[a] gets the label that was assigned to the aes
    # if none are available, just use the required aes

    if length(available_optional_aes) != 0

        optional_mapping_args = merge(
            Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] for a in unlabelled_optional_aes),
            Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] => labs.values[a] for a in labelled_optional_aes)
        )

        layer = data * geom.analysis * geom.visual * mapping(mapping_args...; optional_mapping_args...)

    else
        layer = data * geom.analysis * geom.visual * mapping(mapping_args...)
    end    

    return layer
end

function draw_ggplot(plot::GGPlot)
    layers = []
    empty_layer = mapping()
    
    for geom in plot.geoms
        # if data is not specified at the geom level, use the ggplot default
        if layer_equal(geom.data, empty_layer)
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

        push!(layers, geom_to_layer(geom, data, plot.labs))
    end

    supported_label_options = Dict("title" => "title",
                                   "subtitle" => "subtitle",
                                   "y" => "ylabel",
                                   "x" => "xlabel",
                                   "limits" => "limits",
                                   "xscale" => "xscale",
                                   "yscale" => "yscale",
                                   "xreversed" => "xreversed",
                                   "yreversed" => "yreversed")

    provided_label_options = intersect(
        keys(supported_label_options),
        keys(plot.labs.values)
    )

    # this creates a named tuple
    label_options = (;[Symbol(supported_label_options[key]) => plot.labs.values[key] for key in provided_label_options]...)

    if length(layers) == 0
        println("Warning: No geoms supplied")
    elseif length(layers) == 1
        draw(layers[1]; axis = merge(plot.axis, label_options))
    else
        draw((+)(layers...); axis = merge(plot.axis, label_options))
    end
end

end

