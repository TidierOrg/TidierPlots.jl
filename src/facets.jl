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

"""
Internal function. Given a list of names and (optionally) some constraints, return a Dict{name::String, position::Tuple} that gives the relative position of the facet. 
"""
function position_facets(names; nrow = nothing, ncol = 3, labels = true, boxes = true)
    !isnothing(nrow) && !isnothing(ncol) && nrow * ncol < length(names)
        len = length(names)
        space = nrow * ncol
        throw("Settings for nrow and ncol do not allow enough space to plot all facets (required: $len, available: $space)")
    end

    if isnothing(nrow) && isnothing(ncol)
        throw("No constraints set for facet layout.")
    elseif isnothing(nrow) && !isnothing(ncol)
        nrow = length(names) % ncol == 0 ? length(names) ÷ ncol : length(names) ÷ ncol + 1
    elseif !isnothing(nrow) && isnothing(ncol)
        ncol = length(names) % nrow == 0 ? length(names) ÷ nrow : length(names) ÷ nrow + 1
    end

    # now we have a value for nrow and ncol

    plot_positions = Dict{Any, Tuple}(name => (i, j) for (i, j, name) in zip(repeat(1:ncol, nrow), repeat(1:nrow, inner = ncol), names))
    
    return plot_positions
end