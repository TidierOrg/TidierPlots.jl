# these functions are not tested since logging is currently turned off for testing

# COV_EXCL_START

function Base.show(io::IO, geom::Geom)
    if plot_log[]
        mapping = Pair[]

        for aes in geom.required_aes
            if haskey(geom.aes, aes)
                push!(mapping, aes => geom.aes[aes])
            end
        end

        for k in keys(geom.aes)
            if !(k in geom.required_aes)
                push!(mapping, k => geom.aes[k])
            end
        end

        for k in keys(geom.args)
            if k != "geom_name"
                push!(mapping, Symbol(k) => geom.args[k])
            end
        end

        @info "$(geom.args["geom_name"])" mapping...
    end
end

function Base.show(io::IO, plot::GGPlot)
    if plot_log[]
        log = Pair[]
        if !isnothing(plot.data)
            push!(log, :data => plot.data)
        end

        for (k, v) in plot.default_aes
            push!(log, k => v)
        end

        for k in keys(plot.axis_options)
            if k != "data"
                v = plot.axis_options[k]
                push!(log, k => v)
            end
        end

        @info "ggplot" log...
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

# COV_EXCL_STOP
