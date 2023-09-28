function Base.show(io::IO, geom::Geom)
    name = geom.args["geom_name"]
    printstyled(io, "$name\n", underline = true)
    if haskey(geom.args, "data")
        if geom.args["data"] isa DataFrame
            ref_data = "A DataFrame"
        else
            ref_data = geom.args["data"]
        end

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

    for k in keys(geom.aes)
        if !(k in geom.required_aes)
            v = geom.aes[k]
            println("$k: $v")
        end
    end 
end

function Base.show(io::IO, plot::GGPlot)
    printstyled(io, "ggplot options\n", underline = true)

    if haskey(plot.axis_options, "data")
        if plot.axis_options["data"] isa DataFrame
            ref_data = "A DataFrame"
        else
            ref_data = plot.axis_options["data"]
        end
        
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