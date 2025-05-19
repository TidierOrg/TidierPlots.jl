jitter_positions(args::Tuple{Dict{Symbol, Pair}, Dict{Any, Any}, Vector{String}, DataFrame}) = jitter_positions(args...)

function jitter_positions(aes_dict::Dict{Symbol,Pair},
                          args_dict::Dict{Any,Any},
                          required_aes::Vector{String},
                          plot_data::DataFrame)

    w = pop!(args_dict, "jitter_width",  10)   # horizontal jitter
    h = pop!(args_dict, "jitter_height", 10)   # vertical   jitter

    # uniform noise
    n = nrow(plot_data)
    
    marker_offset(x) = zip(
        round.(Int64, (rand(n) .- 0.5) .* 2w), 
        round.(Int64, (rand(n) .- 0.5) .* 2h)
    ) |> collect

    aes_dict[:marker_offset] = aes_dict[:x][1] => marker_offset

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