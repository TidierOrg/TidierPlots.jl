"""
    facet_grid(;rows, cols, scales = "fixed", switch = "none")

facet_grid() forms a matrix of panels defined by row and column faceting variables. It is most useful when you have two discrete variables, and all combinations of the variables exist in the data. If you have only one variable with many levels, try facet_wrap().

# Arguments

- `rows` (required): Variable to use for the rows of the matrix
- `cols` (required): Variable to use for the columns of the matrix
- `scales` (optional): Should the scales be fixed or free? Options: "free", "free_x", "free_y"
- `switch` (optional): Flip the labels from their default "top and right". Options: "x", "y", "both".
"""
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

    labels = :topright
    if haskey(d, :switch)
        if d[:switch] == "x"
            labels = :topleft
        elseif d[:switch] == "y"
            labels = :bottomright
        elseif d[:switch] == "both"
            labels = :bottomleft
        end
    end

    return FacetOptions(
        Symbol(get(d, :rows, nothing)),
        Symbol(get(d, :cols, nothing)),
        nothing,
        nothing,
        nothing,
        free_x,
        free_y,
        labels
    )
end

"""
    facet_wrap(;rows, cols, scales = "fixed")

facet_wrap() arrange panel in a matrix with 3 columns and as many rows as needed. It is most useful when you have one discrete variables. If you have two variables with many levels, try facet_grid().

# Arguments

- `rows` (required): Variable to use for the rows of the matrix
- `scales` (optional): Should the scales be fixed or free? Options: "free", "free_x", "free_y"
"""
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

    labels = get(d, :labels, :all)

    return FacetOptions(
        nothing,
        nothing,
        Symbol(wrap),
        get(d, :nrow, nothing),
        get(d, :ncol, 3),
        free_x,
        free_y,
        labels
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

function position_facets(names::Vector{Tuple{T,T}}, rows=nothing, cols=nothing, labels=:topright) where {T}
    unique_rows = unique([a[1] for a in names])
    unique_cols = unique([a[2] for a in names])

    rows = length(unique_rows)
    cols = length(unique_cols)

    # plot_positions is a Dict{Any,Tuple} that matches each of the
    # names to a position Tuple

    plot_positions = Dict{Any,Tuple}()

    for (ir, r) in enumerate(unique_rows)
        for (ic, c) in enumerate(unique_cols)
            push!(plot_positions, (r, c) => (ir, ic))
        end
    end

    label_dict = Dict{Tuple,Any}()
    box_dict = Dict{Tuple,Any}()

    # put labels on top
    if labels in [:topleft, :topright]
        label_dict = merge(label_dict, Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10)) for (i, j, name) in zip(repeat([1], cols), 1:cols, unique_cols)))
        box_dict = merge(box_dict, Dict{Tuple,Any}((i, j, Makie.Top()) => Makie.SpecApi.Box() for (i, j, name) in zip(repeat([1], cols), 1:cols, unique_cols)))
    end

    #put labels on right
    if labels in [:bottomright, :topright]
        label_dict = merge(label_dict, Dict{Tuple,Any}((i, j, Makie.Right()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10), rotation = 3π/2) for (i, j, name) in zip(1:rows, repeat([length(unique_cols)], rows), unique_rows)))
        box_dict = merge(box_dict, Dict{Tuple,Any}((i, j, Makie.Right()) => Makie.SpecApi.Box() for (i, j, name) in zip(1:rows, repeat([length(unique_cols)], rows), unique_rows)))
    end

    #put labels on bottom

    if labels in [:bottomright, :bottomleft]
        label_dict = merge(label_dict, Dict{Tuple,Any}((i, j, Makie.Bottom()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10)) for (i, j, name) in zip(repeat([length(unique_rows)], cols), 1:cols, unique_cols)))
        box_dict = merge(box_dict, Dict{Tuple,Any}((i, j, Makie.Bottom()) => Makie.SpecApi.Box() for (i, j, name) in zip(repeat([length(unique_rows)], cols), 1:cols, unique_cols)))
    end

    #put labels on left
    if labels in [:bottomleft, :topleft]
        label_dict = merge(label_dict, Dict{Tuple,Any}((i, j, Makie.Left()) => Makie.SpecApi.Label(text=name, padding=(8, 10, 8, 10), rotation = π/2) for (i, j, name) in zip(1:rows, repeat([1], rows), unique_rows)))
        box_dict = merge(box_dict, Dict{Tuple,Any}((i, j, Makie.Left()) => Makie.SpecApi.Box() for (i, j, name) in zip(1:rows, repeat([1], rows), unique_rows)))
    end

    return (plot_positions, box_dict, label_dict)
end
