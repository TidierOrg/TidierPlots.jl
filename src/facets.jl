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

@testitem "Facets" setup=[TidierPlotsSetup] begin
    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species)

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species)

    @test plot_images_equal(t1, t2)

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm))
        facet_wrap(facets=:species)
    end

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm))
        facet_grid(rows=:species, cols=:sex)
    end

    @test_throws ArgumentError ggplot(penguins) +
                               geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
                               facet_wrap(:species, :sex)

    @test_throws ArgumentError facet_grid(:col1)
    fg = facet_grid(rows=:col1, cols=:col2)

    @test fg.cols == :col2
    @test fg.rows == :col1

    fg = facet_grid(rows=:col1, cols=:col2, scales="free_x")
    @test fg.free_x
    @test !fg.free_y

    fg = facet_grid(rows=:col1, cols=:col2, scales="free_y")
    @test fg.free_y
    @test !fg.free_x

    fg = facet_grid(rows=:col1, cols=:col2, scales="free")
    @test fg.free_x
    @test fg.free_y

    fw = facet_wrap(:col1, scales="free_x")
    @test fw.free_x
    @test !fw.free_y

    fw = facet_wrap(:col1, scales="free_y")
    @test fw.free_y
    @test !fw.free_x

    fw = facet_wrap(:col1, scales="free")
    @test fw.free_x
    @test fw.free_y

    p, b, l = TidierPlots.position_facets(["a", "b"])
    @test p["a"] == (1, 1)
    @test p["b"] == (1, 2)
    @test haskey(b, (1, 2, Top()))
    @test haskey(b, (1, 1, Top()))
    @test haskey(l, (1, 2, Top()))
    @test haskey(l, (1, 1, Top()))
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], nothing, nothing)
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], 1, 1)

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, 1, :top)
    @test p["b"] == (2, 1)
    @test length(l) == 1

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, 1, :none)
    @test length(l) == 0

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, nothing, :none)
    @test length(l) == 0

    # test that non-numeric automatic limit scaling is working with facets

    t1 = ggplot(penguins) +
        geom_bar(aes(x=:sex)) +
        facet_wrap(:sex)

    t2 = ggplot(penguins) +
        geom_bar(aes(x=:sex)) +
        facet_wrap(facets = :sex)

    @test plot_images_equal(t1, t2)

    # free_x and free_y

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free_x")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free_x")

    @test plot_images_equal(t1, t2)

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free_y")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free_y")

    @test plot_images_equal(t1, t2)

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free")

    @test plot_images_equal(t1, t2)

    fg = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm)) +
        facet_grid(rows = :sex, cols = :species, labels = :topright)

    @test plot_will_render(fg)

    p, b, l = TidierPlots.position_facets([("a", "b"), ("c", "d")])

    @test p[("a", "b")] == (1,1)
    @test p[("c", "b")] == (2,1)
    @test p[("c", "d")] == (2,2)
    @test p[("a", "d")] == (1,2)

    p, b, l = TidierPlots.position_facets([("a", "b"), ("c", "d")], nothing, nothing, :bottomleft)
    x = l[(2,1,Makie.Left())]
    @test x.kwargs[:text] == "c"

    tl = facet_grid(rows = :x, cols = :y, switch = "x")
    @test tl.labels == :topleft

    br = facet_grid(rows = :x, cols = :y, switch = "y")
    @test br.labels == :bottomright

    bl = facet_grid(rows = :x, cols = :y, switch = "both")
    @test bl.labels == :bottomleft
end
