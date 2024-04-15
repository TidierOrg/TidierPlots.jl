function handle_position(aes_dict::Dict{String, Symbol},
    args_dict::Dict{Any, Any}, required_aes::Vector{String}, plot_data::DataFrame)
    # handles defaults and grouping for geom_bar/col

    split_var = nothing

    if haskey(args_dict, "position")
        if args_dict["position"] == "dodge"
            if haskey(aes_dict, "group")
                aes_dict["dodge"] = aes_dict["group"]
                split_var = aes_dict["dodge"]
            elseif haskey(aes_dict, "colour")
                aes_dict["dodge"] = aes_dict["colour"]
                split_var = aes_dict["dodge"]
            elseif haskey(aes_dict, "color")
                aes_dict["dodge"] = aes_dict["color"]
                split_var = aes_dict["dodge"]
            end
        elseif args_dict["position"] != "none"
            if haskey(aes_dict, "group")
                aes_dict["stack"] = aes_dict["group"]
                split_var = aes_dict["stack"]
            elseif haskey(aes_dict, "colour")
                aes_dict["stack"] = aes_dict["colour"]
                split_var = aes_dict["stack"]
            elseif haskey(aes_dict, "color")
                aes_dict["stack"] = aes_dict["color"]
                split_var = aes_dict["stack"]
            end
        end
    else
        if haskey(aes_dict, "group")
            aes_dict["stack"] = aes_dict["group"]
            split_var = aes_dict["stack"]
        elseif haskey(aes_dict, "colour")
            aes_dict["stack"] = aes_dict["colour"]
            split_var = aes_dict["stack"]
        elseif haskey(aes_dict, "color")
            aes_dict["stack"] = aes_dict["color"]
            split_var = aes_dict["stack"]
        end
    end

    # for geom_bar, we need to summarize counts
    if args_dict["geom_name"] == "geom_bar"
        if haskey(aes_dict, "x") && !haskey(aes_dict, "y")
            grouping_var = Symbol(aes_dict["x"])
            aes_dict["y"] = :count
            required_aes = ["x", "y"]
        elseif haskey(aes_dict, "y") && !haskey(aes_dict, "x")
            grouping_var = Symbol(aes_dict["y"])
            aes_dict["x"] = :count
            args_dict["direction"] = "x"
            required_aes = ["y", "x"]
        else
            @error "geom_bar requires either an x or y aesthetic, but not both."
        end

        if !isnothing(split_var)
            plot_data = @chain plot_data begin
                groupby([grouping_var, split_var])
                @summarize(count = n())
                @ungroup
            end
        else
            plot_data = @chain plot_data begin
                sort(grouping_var)
                groupby(grouping_var)
                @summarize(count = n())
                @ungroup
            end
        end
    end

    return (aes_dict, args_dict, required_aes, plot_data)
end


"""
    geom_col(aes(...), ...)
    geom_col(plot::GGPlot, aes(...), ...)

Represent data as columns.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `position::String`: "stack" (the default) or "dodge"
- `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# Required Aesthetics

- `x`
- `y`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

- alpha
- colour/color
- fill
- group
- linetype
- linewidth

# Supported Options

- alpha
- colour/color
- fill
- group
- linetype
- linewidth

"""
geom_col = geom_template("geom_col", ["x", "y"], :BarPlot; aes_function = handle_position)

"""
    geom_bar(aes(...), ...)
    geom_bar(plot::GGPlot, aes(...), ...)

Represent data as bars.

# Arguments

- plot::GGPlot (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# Required Aesthetics

- `x` OR `y`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

- alpha
- colour/color
- fill
- group
- linetype
- linewidth

# Supported Options

- alpha
- position: "stack" (the default) or "dodge"
- colour/color
- fill
- group
- linetype
- linewidth
"""
geom_bar = geom_template("geom_bar", String[], :BarPlot; aes_function = handle_position)

"""
    geom_histogram(aes(...), ...)
    geom_histogram(plot::GGPlot, aes(...), ...)

Represents data as a histogram.

# Arguments

- plot::GGPlot (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Hist)

# Required Aesthetics

- `x`

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
geom_histogram = geom_template("geom_histogram", ["x"], :Hist)
