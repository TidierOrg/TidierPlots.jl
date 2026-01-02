"""
    geom_hline(aes(...), ...)
    geom_hline(plot::GGPlot, aes(...), ...)

Plot a horizontal line at the given y-intercept(s).

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.HLines)

# Required Aesthetics

- NA

# Optional Aesthetics (see [`aes`](@ref))

- `yintercept(s)`
- `color` / `colour`

# Optional Arguments

- `yintercept(s)`
- `color` / `colour`
- `linewidth`
- `linestyle` / `linetype`
- `colormap` / `palette`
- `alpha`

# Examples

```julia
# Plot only a single y-intercept
ggplot() + geom_hline(yintercept = 3)

# Plot multiple y-intercepts
ggplot() + geom_hline(yintercept = [-1, 4])

# Plot multiple y-intercepts mapped to a column
df = DataFrame(y = rand(4))
ggplot(df, @aes(yintercept = y)) + geom_hline()
```
"""
function geom_hline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_hline"

    if haskey(args_dict, "yintercept")
        yint_values = args_dict["yintercept"]
        # Convert Date/DateTime to numeric values
        if yint_values isa Dates.Date
            yint_values = Float64(Dates.value(yint_values))
        elseif yint_values isa Dates.DateTime
            yint_values = Float64(Dates.value(yint_values))
        elseif yint_values isa AbstractVector && length(yint_values) > 0
            if yint_values[1] isa Dates.Date
                yint_values = Float64.(Dates.value.(yint_values))
            elseif yint_values[1] isa Dates.DateTime
                yint_values = Float64.(Dates.value.(yint_values))
            end
        end
        args_dict["data"] = DataFrame(Numeric = yint_values)
        aes_dict[:yintercept] = :Numeric => identity
    end

    return build_geom(aes_dict, args_dict,
        ["yintercept"], # required aesthetics
        :HLines) # function for visual layer
end

"""
    geom_vline(aes(...), ...)
    geom_vline(plot::GGPlot, aes(...), ...)

Plot a horizontal line at the given y-intercept(s).

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.VLines)

# Required Aesthetics

- NA

# Optional Aesthetics (see [`aes`](@ref))

- `xintercept(s)`
- `color` / `colour`

# Optional Arguments

- `xintercept(s)`
- `color` / `colour`
- `linewidth`
- `linestyle` / `linetype`
- `colormap` / `palette`
- `alpha`

# Examples

```julia
# Plot only a single x-intercept
ggplot() + geom_vline(xintercept = 3)

# Plot multiple x-intercepts
ggplot() + geom_vline(xintercept = [-1, 4])

# Plot multiple x-intercepts mapped to a column
df = DataFrame(x = rand(4))
ggplot(df, @aes(xintercept = x)) + geom_vline()
```
"""
function geom_vline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_vline"

    if haskey(args_dict, "xintercept")
        xint_values = args_dict["xintercept"]
        # Convert Date/DateTime to numeric values
        if xint_values isa Dates.Date
            xint_values = Float64(Dates.value(xint_values))
        elseif xint_values isa Dates.DateTime
            xint_values = Float64(Dates.value(xint_values))
        elseif xint_values isa AbstractVector && length(xint_values) > 0
            if xint_values[1] isa Dates.Date
                xint_values = Float64.(Dates.value.(xint_values))
            elseif xint_values[1] isa Dates.DateTime
                xint_values = Float64.(Dates.value.(xint_values))
            end
        end
        args_dict["data"] = DataFrame(Numeric = xint_values)
        aes_dict[:xintercept] = :Numeric => identity
    end

    return build_geom(aes_dict, args_dict,
        ["xintercept"], # required aesthetics
        :VLines) # function for visual layer
end

function geom_hline(plot::GGPlot, args...; kwargs...)
    return plot + geom_hline(args...; kwargs...)
end

function geom_vline(plot::GGPlot, args...; kwargs...)
    return plot + geom_vline(args...; kwargs...)
end
