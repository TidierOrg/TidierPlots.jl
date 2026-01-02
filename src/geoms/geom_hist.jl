function handle_histogram(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{Any,Any}, required_aes::Vector{String}, plot_data::DataFrame)
    # Handle center, boundary, and binwidth parameters like ggplot2
    # center: specifies that a bin should be centered on this value
    # boundary: specifies that a bin edge should be at this value
    # binwidth: specifies the width of bins

    if haskey(args_dict, "center") || haskey(args_dict, "boundary")
        # Get the data column
        x_col = aes_dict[:x][1]
        x_data = plot_data[!, x_col]
        x_data = collect(skipmissing(x_data))

        # Calculate data range
        data_min = minimum(x_data)
        data_max = maximum(x_data)
        data_range = data_max - data_min

        # Get binwidth - if not specified, calculate from bins count
        if haskey(args_dict, "binwidth")
            binwidth = args_dict["binwidth"]
            delete!(args_dict, "binwidth")
        else
            nbins = get(args_dict, "bins", 30)
            if nbins isa Number
                binwidth = data_range / nbins
            else
                # bins is already a vector, don't override
                return (aes_dict, args_dict, required_aes, plot_data)
            end
        end

        if haskey(args_dict, "center")
            center = args_dict["center"]
            # Calculate bin edges so center is at a bin center
            # Bins are centered at center, center ± binwidth, center ± 2*binwidth, etc.
            lower_count = ceil(Int, (center - data_min) / binwidth + 0.5)
            upper_count = ceil(Int, (data_max - center) / binwidth + 0.5)

            left_edge = center - (lower_count - 0.5) * binwidth
            right_edge = center + (upper_count + 0.5) * binwidth

            bin_edges = collect(left_edge:binwidth:right_edge)
            delete!(args_dict, "center")
        else
            boundary = args_dict["boundary"]
            # Calculate bin edges so boundary is at a bin edge
            lower_count = ceil(Int, (boundary - data_min) / binwidth)
            upper_count = ceil(Int, (data_max - boundary) / binwidth)

            left_edge = boundary - lower_count * binwidth
            right_edge = boundary + upper_count * binwidth

            bin_edges = collect(left_edge:binwidth:right_edge)
            delete!(args_dict, "boundary")
        end

        # Replace bins argument with explicit edges
        args_dict["bins"] = bin_edges
    elseif haskey(args_dict, "binwidth")
        # Handle binwidth without center/boundary
        x_col = aes_dict[:x][1]
        x_data = plot_data[!, x_col]
        x_data = collect(skipmissing(x_data))

        data_min = minimum(x_data)
        data_max = maximum(x_data)

        binwidth = args_dict["binwidth"]
        delete!(args_dict, "binwidth")

        # Create bins from data_min to data_max with given binwidth
        bin_edges = collect(data_min:binwidth:(data_max + binwidth))
        args_dict["bins"] = bin_edges
    end

    return (aes_dict, args_dict, required_aes, plot_data)
end

"""
    geom_histogram(aes(...), ...)
    geom_histogram(plot::GGPlot, aes(...), ...)

Represents data as a histogram.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Hist)

# Required Aesthetics

- `x`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `bins`: number of bins or a vector of bin edges
- `binwidth`: width of each bin (alternative to bins)
- `center`: value that should be at the center of a bin (useful for discrete data)
- `boundary`: value that should be at the edge of a bin
- `normalization`
- `color` / `colour`
- `stroke` / `strokewidth`
- `strokecolor` / `strokecolour`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram()

ggplot(penguins, @aes(x = bill_length_mm)) +
    geom_histogram(normalization=:probability, bins=20)

# For discrete/integer data, use center to align bars with tick marks
# This centers a bin on 0, so tick marks appear at bar centers
ggplot(df, @aes(x = counts)) +
    geom_histogram(binwidth=1, center=0)
```
"""
geom_histogram = geom_template("geom_histogram", ["x"], :Hist;
    pre_function=handle_histogram,
    grouping_aes=[:color, :colour],
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ))
