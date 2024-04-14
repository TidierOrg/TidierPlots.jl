"""
    geom_hline(aes(...), ...)
    geom_hline(plot::GGPlot, aes(...), ...)

Plot a horizontal line at the given y-intercept.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.HLines)

# Required Aesthetics

- `yintercept`

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
function geom_hline end

function geom_hline(args...; kwargs...)
    aes_dict, args_dict, transforms = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_hline"

    if haskey(args_dict, "yintercept")
        args_dict["data"] = DataFrame(Numeric = args_dict["yintercept"])
        aes_dict["yintercept"] = :Numeric
    end

    return build_geom(aes_dict, args_dict,
        ["yintercept"], # required aesthetics
        :HLines,
        do_nothing,
        transforms) # function for visual layer
end

"""
    geom_vline(aes(...), ...)
    geom_vline(plot::GGPlot, aes(...), ...)

Plot a vertical line at the given x-intercept.

# Arguments

- `plot::GGPlot` (optional): a plot object to "add" this geom to
- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column (passed to Makie.XXXXX)

# Required Aesthetics

- `xintercept`

# Supported Optional Aesthetics (See aes() for specification options)

TBD

# Supported Options

TBD
"""
function geom_vline end

function geom_vline(args...; kwargs...)
    aes_dict, args_dict, transforms = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_vline"

    if haskey(args_dict, "xintercept")
        args_dict["data"] = DataFrame(Numeric = args_dict["xintercept"])
        aes_dict["xintercept"] = :Numeric
    end

    return build_geom(aes_dict, args_dict,
        ["xintercept"], # required aesthetics
        :VLines,
        do_nothing,
        transforms) # function for visual layer
end

function geom_hline(plot::GGPlot, args...; kwargs...)
    return plot + geom_hline(args...; kwargs...)
end

function geom_vline(plot::GGPlot, args...; kwargs...)
    return plot + geom_vline(args...; kwargs...)
end
