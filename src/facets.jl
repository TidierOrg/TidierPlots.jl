function facet_grid(args...; kwargs...)
    if length(args) > 0 
        throw("Use keyword args to specify rows and/or columns in facet_grid")
    end

    d = Dict(kwargs)
    
    return FacetOptions(
        Symbol(get(d, :rows, nothing)),
        Symbol(get(d, :cols, nothing)),
        nothing
    )    
end

function facet_wrap(args...; kwargs...)
    if length(args) == 0
        d = Dict(kwargs)
        if length(d) == 1
            wrap = collect(values(d))[1]
        else
            throw("Too many keyword arguments to facet_wrap")
        end
    elseif length(args) == 1
        wrap = args[1]
    else
        throw("Too many arguments to facet_wrap")
    end
    
    return FacetOptions(
        nothing,
        nothing,
        Symbol(wrap)
    )    
end

function facet_wrap(plot::GGPlot, args...; kwargs...)    
    return plot + facet_wrap(args...; kwargs...)
end

function facet_grid(plot::GGPlot, args...; kwargs...)    
    return plot + facet_grid(args...; kwargs...)
end