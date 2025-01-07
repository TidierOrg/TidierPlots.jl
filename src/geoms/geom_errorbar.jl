"""
    geom_errorbar(aes(...), ...)
    geom_errorbar(plot::GGPlot, aes(...), ...)

Represents data as a vertical interval.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# Required Aesthetics

- `x`
- `ymin`
- `ymax`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `color` / `colour`
- `direction=:y`
- `linewidth`
- `whiskerwidth` / `width`

# Examples

```julia
df = DataFrame(
    trt   = [1, 1, 2, 2],
    resp  = [1, 5, 3, 4],
    group = [1, 2, 1, 2],
    lower = [0.8, 4.6, 2.4, 3.6],
    upper = [1.1, 5.3, 3.3, 4.2],
)

ggplot(df, @aes(x = trt, ymin = lower, ymax = upper)) +
    geom_errorbar(width=20, linewidth=2)
```
"""
function geom_errorbar(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbar"

    return build_geom(aes_dict, args_dict,
        ["x", "ymin", "ymax"], # required aesthetics
        :Rangebars; # function for visual layer
        special_aes = Dict("width" => "whiskerwidth"))
end

function geom_errorbar(plot::GGPlot, args...; kwargs...)
    return plot + geom_errorbar(args..., kwargs...)
end


"""
    geom_errorbarh(aes(...), ...)
    geom_errorbarh(plot::GGPlot, aes(...), ...)

Represents data as a horizontal interval.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# Required Aesthetics

- `y`
- `xmin`
- `xmax`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `color` / `colour`
- `direction=:x`
- `linewidth`
- `whiskerwidth` / `width`

# Examples

```julia
df = DataFrame(
    trt   = [1, 1, 2, 2],
    resp  = [1, 5, 3, 4],
    group = [1, 2, 1, 2],
    lower = [0.8, 4.6, 2.4, 3.6],
    upper = [1.1, 5.3, 3.3, 4.2],
)

ggplot(df, @aes(y = trt, xmin = lower, xmax = upper)) +
    geom_errorbarh(width=20, linewidth=2)
```
"""
function geom_errorbarh(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbarh"
    args_dict["errorbar_direction"] = :x

    return build_geom(aes_dict, args_dict,
        ["y", "xmin", "xmax"], # required aesthetics
        :Rangebars; # function for visual layer
        special_aes = Dict("width" => "whiskerwidth"))

end

function geom_errorbarh(plot::GGPlot, args...; kwargs...)
    return plot + geom_errorbarh(args..., kwargs...)
end
