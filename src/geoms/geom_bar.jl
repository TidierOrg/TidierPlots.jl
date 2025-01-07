function handle_position(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{Any,Any}, required_aes::Vector{String}, plot_data::DataFrame)
    # handles defaults and grouping for geom_bar/col

    split_var = nothing

    if haskey(args_dict, "position")
        if args_dict["position"] == "dodge"
            if haskey(aes_dict, :group)
                aes_dict[:dodge] = aes_dict[:group]
                split_var = aes_dict[:dodge][1]
            elseif haskey(aes_dict, :colour)
                aes_dict[:dodge] = aes_dict[:colour]
                split_var = aes_dict[:dodge][1]
            elseif haskey(aes_dict, :color)
                aes_dict[:dodge] = aes_dict[:color]
                split_var = aes_dict[:dodge][1]
            elseif haskey(aes_dict, :fill)
                aes_dict[:dodge] = aes_dict[:fill]
                split_var = aes_dict[:dodge][1]
            end
        elseif args_dict["position"] != "none"
            if haskey(aes_dict, :group)
                aes_dict[:stack] = aes_dict[:group]
                split_var = aes_dict[:stack][1]
            elseif haskey(aes_dict, :colour)
                aes_dict[:stack] = aes_dict[:colour]
                split_var = aes_dict[:stack][1]
            elseif haskey(aes_dict, :color)
                aes_dict[:stack] = aes_dict[:color]
                split_var = aes_dict[:stack][1]
            elseif haskey(aes_dict, :fill)
                aes_dict[:stack] = aes_dict[:fill]
                split_var = aes_dict[:stack][1]
            end
        end
    else
        if haskey(aes_dict, :group)
            aes_dict[:stack] = aes_dict[:group]
            split_var = aes_dict[:stack][1]
        elseif haskey(aes_dict, :colour)
            aes_dict[:stack] = aes_dict[:colour]
            split_var = aes_dict[:stack][1]
        elseif haskey(aes_dict, :color)
            aes_dict[:stack] = aes_dict[:color]
            split_var = aes_dict[:stack][1]
        elseif haskey(aes_dict, :fill)
            aes_dict[:stack] = aes_dict[:fill]
            split_var = aes_dict[:stack][1]
        end
    end

    # for geom_bar, we need to summarize counts
    if args_dict["geom_name"] == "geom_bar"
        if haskey(aes_dict, :x) && !haskey(aes_dict, :y)
            grouping_var = aes_dict[:x][1]
            aes_dict[:y] = :count => identity
            required_aes = ["x", "y"]
        elseif haskey(aes_dict, :y) && !haskey(aes_dict, :x)
            grouping_var = aes_dict[:y][1]
            aes_dict[:x] = :count => identity
            args_dict["direction"] = "x"
            required_aes = ["y", "x"]
        else
            @error "geom_bar requires either an x or y aesthetic, but not both."
        end

        if !isnothing(split_var)
            plot_data = @chain plot_data begin
                groupby([grouping_var; split_var])
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

# Details

The columns are stacked by default, and the behavior can be changed with the "position"
argument. The position can either be "stack" or "dodge". If the argument is "dodge", then a
a grouping variable will also need to be supplied to `aes`. Alternatively you can supply the
grouping variable to `dodge` within the aesthetic.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `strokecolor` / `strokecolour`
- `dodge`
- `group`

# Optional Arguments

- `position`: "stack" (default) or "dodge"
- `stroke` / `strokewidth`
- `strokecolor` / `strokecolour`
- `direction`: `:y` (default) or :x
- `dodge_gap`
- `gap`

# Examples

```julia
df = @chain penguins begin
    @group_by(species, sex)
    @summarize(mean_bill_length_mm = mean(bill_length_mm))
    @ungroup()
end

ggplot(df) +
    geom_col(@aes(x = species, y = mean_bill_length_mm))

# dodge using the group and position arguments
ggplot(df) +
    geom_col(@aes(x = species, y = mean_bill_length_mm, group = sex),
             position="dodge")

# dodge using the dodge aesthetic
ggplot(df) +
    geom_col(@aes(x = species, y = mean_bill_length_mm, dodge = sex))

# color based on grouping variable
ggplot(df) +
    geom_col(@aes(x = species, y = mean_bill_length_mm, color = sex))
```
"""
geom_col = geom_template("geom_col", ["x", "y"], :BarPlot; pre_function=handle_position)

"""
    geom_bar(aes(...), ...)
    geom_bar(plot::GGPlot, aes(...), ...)

Represent the counts of a grouping variable as columns.

# Details

The columns are stacked by default, and the behavior can be changed with the "position"
argument. The position can either be "stack" or "dodge". If the argument is "dodge", then a
a grouping variable will also need to be supplied to `aes`. Alternatively you can supply the
grouping variable to `dodge` within the aesthetic.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.BarPlot)

# Required Aesthetics

- `x` OR `y` (not both)

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`
- `strokecolor` / `strokecolour`
- `dodge`
- `group`

# Optional Arguments

- `position`: "stack" (default) or "dodge"
- `stroke` / `strokewidth`
- `strokecolor` / `strokecolour`
- `direction`: `:y` (default) or :x
- `dodge_gap`
- `gap`

# Examples

```julia
# vertical bar plot
ggplot(penguins) + geom_bar(@aes(x = species))

# horizontal bar plot
ggplot(penguins) + geom_bar(@aes(y = species))

# stacked
ggplot(penguins, @aes(x = species, fill=sex)) + geom_bar()

# dodged
ggplot(penguins, @aes(x = species, fill=sex, dodge = sex)) + geom_bar()
```
"""
geom_bar = geom_template("geom_bar", String[], :BarPlot;
    pre_function=handle_position,
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ))
