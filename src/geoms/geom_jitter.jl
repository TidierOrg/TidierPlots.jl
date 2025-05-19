jitter_positions(args::Tuple{Dict{Symbol, Pair}, Dict{Any, Any}, Vector{String}, DataFrame}) = jitter_positions(args...)

function jitter_positions(aes_dict::Dict{Symbol,Pair},
                          args_dict::Dict{Any,Any},
                          required_aes::Vector{String},
                          plot_data::DataFrame)

    w = get(args_dict, "jitter_width",  0.4)   # horizontal jitter
    h = get(args_dict, "jitter_height", 0.4)   # vertical   jitter

    function numericise(df::DataFrame, colname::Symbol)
        col = df[!, colname]
        eltype(col) <: Number && return col              
        mapping = Dict(v => i for (i, v) in enumerate(unique(col)))
        return Float64.(getindex.(Ref(mapping), col))
    end

    # Add uniform noise
    jitter(col, amt) = col .+ (rand(length(col)) .- 0.5) .* amt

    if :x ∈ keys(aes_dict)
        xcol = aes_dict[:x][1]
        plot_data[!, xcol] = jitter(numericise(plot_data, xcol), w)
    end
    if :y ∈ keys(aes_dict)
        ycol = aes_dict[:y][1]
        plot_data[!, ycol] = jitter(numericise(plot_data, ycol), h)
    end

    return (aes_dict, args_dict, required_aes, plot_data)
end


"""
geom_jitter(aes(...); width = 0.4, height = 0.4, …)

Scatter plot with random position noise to mitigate over-plotting.

# Required aesthetics
- `x`
- `y`

"""
geom_jitter = geom_template(
    "geom_jitter",
    ["x", "y"],
    :Scatter;
    pre_function = jitter_positions ∘ handle_point_color_and_fill
)