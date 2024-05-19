function facet_grid(args...; kwargs...)
    if length(args) > 0 
        throw("Use keyword args to specify rows and/or columns in facet_grid")
    end

    d = Dict(kwargs)

    free_x = false
    free_y = false
    
    if haskey(d, :scales)
        if d[:scales] == "free"
            free_x = true
            free_y = true
        elseif d[:scales] == "free_x"
            free_x = true
        elseif d[:scales] == "free_y"
            free_y = true
        end
    end
    
    return FacetOptions(
        Symbol(get(d, :rows, nothing)),
        Symbol(get(d, :cols, nothing)),
        nothing,
        get(d, :nrow, nothing),
        get(d, :ncol, 3),
        free_x,
        free_y
    )    
end

function facet_wrap(args...; kwargs...)
    d = Dict(kwargs)

    if length(args) == 1
        wrap = args[1]
    elseif length(args) == 0
        wrap = get(d, :facets)
    else
        throw("Too many arguments to facet_wrap")
    end

    free_x = false
    free_y = false
    
    if haskey(d, :scales)
        if d[:scales] == "free"
            free_x = true
            free_y = true
        elseif d[:scales] == "free_x"
            free_x = true
        elseif d[:scales] == "free_y"
            free_y = true
        end
    end

    return FacetOptions(
        nothing,
        nothing,
        Symbol(wrap),
        get(d, :nrow, nothing),
        get(d, :ncol, 3),
        free_x,
        free_y
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
function position_facets(names, rows = nothing, cols = 3, labels = true, boxes = true)
    if (!isnothing(rows) && !isnothing(cols))
        if (rows * cols < length(names))
            len = length(names)
            space = rows * cols
            throw("Settings for nrow and ncol do not allow enough space to plot all facets (required: $len, available: $space)")
        end
    end

    if isnothing(rows) && isnothing(cols)
        throw("No constraints set for facet layout.")
    elseif isnothing(rows) && !isnothing(cols)
        rows = length(names) % cols == 0 ? length(names) ÷ cols : length(names) ÷ cols + 1
    elseif !isnothing(rows) && isnothing(cols)
        cols = length(names) % rows == 0 ? length(names) ÷ rows : length(names) ÷ rows + 1
    end

    # now we have a value for nrow and ncol

    plot_positions = Dict{Any, Tuple}(name => (i, j) for (i, j, name) in zip(repeat(1:rows, inner = cols), repeat(1:cols, rows), names))
    
    return plot_positions
end