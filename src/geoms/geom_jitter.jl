function jitter_positions(aes_dict::Dict{Symbol,Pair},
                          args_dict::Dict{Any,Any},
                          required_aes::Vector{String},
                          plot_data::DataFrame)

    w = pop!(args_dict, "width",  0.4)   # horizontal jitter
    h = pop!(args_dict, "height", 0.4)   # vertical   jitter

    function numericise!(df::DataFrame, colname::Symbol)
        col = df[!, colname]
        eltype(col) <: Number && return               
        
        mapping = Dict(v => i for (i, v) in enumerate(unique(col)))
        df[!, colname] = Float64.(getindex.(Ref(mapping), col))
    end

    # Add uniform noise in-place
    jitter!(col, amt) = col .+= (rand(length(col)) .- 0.5) .* amt

    if :x ∈ keys(aes_dict)
        xcol = aes_dict[:x][1]
        numericise!(plot_data, xcol)
        jitter!(plot_data[!, xcol], w)
    end
    if :y ∈ keys(aes_dict)
        ycol = aes_dict[:y][1]
        numericise!(plot_data, ycol)
        jitter!(plot_data[!, ycol], h)
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
    pre_function = jitter_positions,
    special_aes  = Dict(
    :colour => :color,
    :fill   => :color,
    :color  => :color,
    ),
)