function facet_grid(args...; kwargs...)
    if length(args) > 0
        throw(ArgumentError("Use keyword args to specify rows and/or cols in facet_grid"))
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
        wrap = get(d, :facets, nothing)
        isnothing(wrap) && throw(ArgumentError("Specify facet variable with 'facets' keyword argument or as the only positional argument (i.e. facet_wrap(:colname))"))
    else
        throw(ArgumentError("Too many arguments to facet_wrap"))
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
Internal function. Given a list of names and (optionally) some constraints, return the relative position of the facets and their labels.
"""
function position_facets(names, rows=nothing, cols=3, labels=:all)
    if (!isnothing(rows) && !isnothing(cols))
        if (rows * cols < length(names))
            len = length(names)
            space = rows * cols
            throw(ArgumentError("Settings for nrow and ncol do not allow enough space to plot all facets (required: $len, available: $space)"))
        end
    end

    if isnothing(rows) && isnothing(cols)
        throw(ArgumentError("No constraints set for facet layout."))
    elseif isnothing(rows) && !isnothing(cols)
        rows = length(names) % cols == 0 ?
               length(names) ÷ cols : length(names) ÷ cols + 1
    elseif !isnothing(rows) && isnothing(cols)
        cols = length(names) % rows == 0 ?
               length(names) ÷ rows : length(names) ÷ rows + 1
    end

    # now we have a value for nrow and ncol

    plot_positions = Dict{Any,Tuple}(name => (i, j) for (i, j, name) in zip(repeat(1:rows, inner=cols), repeat(1:cols, rows), names))

    label_dict = Dict{Tuple,Any}()
    box_dict = Dict{Tuple,Any}()

    if labels == :all
        label_dict = Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10)) for (i, j, name) in zip(repeat(1:rows, inner=cols), repeat(1:cols, rows), names))
        box_dict = Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Box() for (i, j, name) in zip(repeat(1:rows, inner=cols), repeat(1:cols, rows), names))
    elseif labels == :top
        label_dict = Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10)) for (i, j, name) in zip(repeat([1], cols), 1:cols, names))
        box_dict = Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Box() for (i, j, name) in zip(repeat([1], cols), 1:cols, names))
    elseif labels == :none
        label_dict = Dict{Tuple,Any}()
        box_dict = Dict{Tuple,Any}()
    end

    return (plot_positions, box_dict, label_dict)
end

function position_facets(names::Vector{Tuple}, rows=nothing, cols=nothing, labels=:all)
    unique_rows = unique([a[1] for a in names])
    unique_cols = unique([a[2] for a in names])

    nrow = length(unique_rows)
    ncol = length(unique_cols)


end
