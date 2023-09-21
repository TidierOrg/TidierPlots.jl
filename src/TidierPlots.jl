module TidierPlots

using Makie
using CairoMakie
using AlgebraOfGraphics
using DataFrames
using Reexport

include("structs.jl")
include("geom.jl")
include("labs.jl")
include("scales.jl")
include("interop.jl")

include("geom_bar.jl")
include("geom_boxplot.jl")
include("geom_contour.jl")
include("geom_errorbar.jl")
include("geom_density.jl")
include("geom_path.jl")
include("geom_point.jl")
include("geom_smooth.jl")
include("geom_text.jl")
include("geom_violin.jl")

@reexport using Makie: theme_black, theme_dark, theme_ggplot2, theme_light, theme_minimal

export draw_ggplot, geom_to_layer, ggplot_to_layers, layer_equal, @ggplot
export Layer, Layers
export @geom_point, @geom_smooth 
export @geom_bar, @geom_col, @geom_histogram
export @geom_errorbar, @geom_errorbarh
export @geom_path, @geom_line, @geom_step
export @geom_violin, @geom_boxplot
export @geom_contour, @geom_tile
export @geom_text, @geom_label
export @geom_density
export @labs, @lims
export @scale_x_continuous, @scale_y_continuous
export @scale_x_log10, @scale_y_log10, @scale_x_log2, @scale_y_log2, @scale_x_log, @scale_y_log  
export @scale_x_logit, @scale_y_logit 
export @scale_x_pseudolog10, @scale_y_pseudolog10, @scale_x_Symlog10, @scale_y_Symlog10 
export @scale_x_reverse, @scale_y_reverse, @scale_x_sqrt, @scale_y_sqrt
export @scale_colour_continuous, @scale_colour_continuous

const autoplot = Ref{Bool}(true)

function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "autoplot"
       autoplot[] = value
    else
      throw("That is not a valid option.")
    end
end

function Base.:+(x::GGPlot, y...)::GGPlot
    result = GGPlot(
        vcat(x.geoms, [i for i in y if i isa Geom]), 
        x.default_aes, 
        x.data,
        merge(x.axis_options, 
            [l.axis_options for l in y if l isa Geom]...,
            [d for d in y if d isa Dict]...)
    )

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

    if !haskey(args_dict, "height")
        args_dict["height"] = 400
    end
    
    if !haskey(args_dict, "width")
        args_dict["width"] = 600
    end

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = mapping()
    
    GGPlot([], 
           aes_dict, 
           plot_data,
           args_dict) 
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

function check_aes(required_aes, aes_dict, geom_name)
    missing_aes = [aes for aes in required_aes if !haskey(aes_dict, aes)]

    if (length(missing_aes) != 0)
        error("$geom_name is missing required aesthetic(s): $missing_aes")
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
    
    check_aes(geom.required_aes, geom.aes, geom.args["geom_name"])

    visual_layer = geom.visual

    if haskey(labs, "palette")
        visual_layer = geom.visual * AlgebraOfGraphics.visual(colormap = labs["palette"])
    end

    mapping_args_array = []

    # rename required aes if labs are given
    # this section is possibly not required with the current geoms
    # as x and y will be renamed elsewhere
    # it is retained in case geoms with required aes other than ["x", "y"]
    # are implemented 

    for key in geom.required_aes
        if !haskey(labs, key)
            push!(mapping_args_array, Symbol(geom.aes[key]))
        else 
            push!(mapping_args_array, Symbol(geom.aes[key]) => labs[key])
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
        keys(labs),
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
            Dict(Symbol(geom.optional_aes[a]) => geom.aes[a] => labs[a] for a in labelled_optional_aes)
        )

        layer = data * geom.analysis * visual_layer * mapping(mapping_args...; optional_mapping_args...)

    else
        layer = data * geom.analysis * visual_layer * mapping(mapping_args...)
    end    

    return layer
end

function draw_ggplot(plot::GGPlot)
    
    layers = Layers(plot)

    supported_label_options = Dict("title" => "title",
                                   "subtitle" => "subtitle",
                                   "y" => "ylabel",
                                   "x" => "xlabel",
                                   "height" => "height",
                                   "width" => "width",
                                   "limits" => "limits",
                                   "xscale" => "xscale",
                                   "yscale" => "yscale",
                                   "xreversed" => "xreversed",
                                   "yreversed" => "yreversed")

    provided_label_options = intersect(
        keys(supported_label_options),
        keys(plot.axis_options)
    )

    # this creates a named tuple
    label_options = (;[Symbol(supported_label_options[key]) => plot.axis_options[key] for key in provided_label_options]...)

    draw(layers; axis = label_options)
end

function Base.show(io::IO, geom::Geom)
    name = geom.args["geom_name"]
    printstyled(io, "$name\n", underline = true)
    if haskey(geom.args, "data")
        ref_data = geom.args["data"]
        row_count = nrow(DataFrame(geom.data.data))
        col_count = ncol(DataFrame(geom.data.data))
        printstyled(io, "data: $ref_data ($row_count rows, $col_count columns)\n", color = :green)
    else
        printstyled(io, "data: inherits from plot\n", color = :blue)
    end

    for aes in geom.required_aes
        if haskey(geom.aes, aes)
            colname = geom.aes[aes]
            printstyled(io, "$aes: ", color = :green)
            if haskey(geom.args, "data")
                if String(colname) in names(DataFrame(geom.data.data))
                    printstyled(io, "$colname \n", color = :green)
                else
                    printstyled(io, "$colname \n", color = :red)
                end
            else
                printstyled(io, "$colname \n", color = :blue)
            end
        else
            printstyled(io, "$aes: not specified \n", color = :yellow)
        end
    end
end

function Base.show(io::IO, plot::GGPlot)
    printstyled(io, "ggplot options\n", underline = true)

    if haskey(plot.axis_options, "data")
        ref_data = plot.axis_options["data"]
        row_count = nrow(DataFrame(plot.data.data))
        col_count = ncol(DataFrame(plot.data.data))
        printstyled(io, "data: $ref_data ($row_count rows, $col_count columns)\n", color = :blue)
    end

    for k in keys(plot.axis_options)
        if k != "data"
            v = plot.axis_options[k]
            println("$k: $v")
        end
    end

    println("")

    for g in plot.geoms
        println(g)
    end
end

end