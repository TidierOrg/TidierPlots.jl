"""
    geom_errorbar(aes(...), ...)
    geom_errorbar(plot::GGPlot, aes(...), ...)

Represents data as a vertical interval.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# Required Aesthetics

TBD

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
function geom_errorbar end

function geom_errorbar(args...; kwargs...)
    aes_dict, args_dict, transforms = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbar"

    return build_geom(aes_dict, args_dict,
        ["x", "ymin", "ymax"], # required aesthetics
        :Rangebars, # function for visual layer
        do_nothing,
        transforms;
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

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.Rangebars)

# Required Aesthetics

TBD

# Supported Optional Aesthetics (See [`aes`](@ref) for specification options)

TBD

# Supported Options

TBD
"""
function geom_errorbarh end

function geom_errorbarh(args...; kwargs...)
    aes_dict, args_dict, transforms = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_errorbarh"
    args_dict["errorbar_direction"] = :x

    return build_geom(aes_dict, args_dict,
        ["y", "xmin", "xmax"], # required aesthetics
        :Rangebars, # function for visual layer
        do_nothing,
        transforms;
        special_aes = Dict("width" => "whiskerwidth"))

end

function geom_errorbarh(plot::GGPlot, args...; kwargs...)
    return plot + geom_errorbarh(args..., kwargs...)
end
