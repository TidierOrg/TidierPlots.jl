function Base.show(io::IO, geom::Geom)
    if plot_log[]
        name = geom.args["geom_name"]
        printstyled(io, "$name\n", underline = true)
        if haskey(geom.args, "data")
            if geom.args["data"] isa DataFrame
                ref_data = "A DataFrame"
            else
                ref_data = geom.args["data"]
            end

            row_count = nrow(geom.data)
            col_count = ncol(geom.data)
            printstyled(io, "data: $ref_data ($row_count rows, $col_count columns)\n", color = :green)
        else
            printstyled(io, "data: inherits from plot\n", color = :blue)
        end

        for aes in geom.required_aes
            if haskey(geom.aes, aes)
                colname = geom.aes[aes]
                printstyled(io, "$aes: ", color = :green)
                if haskey(geom.args, "data")
                    if String(colname) in names(DataFrame(geom.data))
                        printstyled(io, "$colname \n", color = :green)
                    else
                        printstyled(io, "$colname \n", color = :red)
                    end
                else
                    printstyled(io, "$colname \n", color = :blue)
                end
            else
                printstyled(io, "$aes: inherits from plot \n", color = :yellow)
            end
        end

        for k in keys(geom.aes)
            if !(k in geom.required_aes)
                v = geom.aes[k]
                println("$k: $v")
            end
        end
    end
end

function Base.show(io::IO, plot::GGPlot)
    if plot_log[]
        printstyled(io, "ggplot options\n", underline = true)

        if !isnothing(plot.data)
            row_count = nrow(DataFrame(plot.data))
            col_count = ncol(DataFrame(plot.data))
            printstyled(io, "data: A DataFrame ($row_count rows, $col_count columns)\n", color = :blue)
        end

        for (k, v) in plot.default_aes
            printstyled(io, "$k: $v\n", color = :yellow)
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

    if plot_show[]
        with_theme(plot.theme) do
            display(draw_ggplot(plot))
        end
    end
end

function Base.show(io::IO, plot_grid::GGPlotGrid)
    if plot_log[]
        for p in plot_grid.plots
            println(p)
        end
    end

    if plot_show[]
        with_theme(plot_grid.plots[1].theme) do
            display(draw_ggplot(plot_grid))
        end
    end
end

function Base.show(io::IO, ::MIME"text/html", x::GGPlot)
	show(io, MIME"text/html"(),
        with_theme(x.theme) do
            draw_ggplot(x)
        end
    )
end

function Base.show(io::IO, ::MIME"text/html", x::GGPlotGrid)
	show(io, MIME"text/html"(),
        with_theme(x.plots[1].theme) do
            draw_ggplot(x)
        end
    )
end
