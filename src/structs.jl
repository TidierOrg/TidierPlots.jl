struct ggplot
    geoms::AbstractArray
    default_aes::Dict
    data::Symbol
    axis::NamedTuple
end

struct geom
    visual::Union{Symbol, Nothing}
    aes::Dict
    args::Dict
    analysis::Any
    required_aes::AbstractArray
end

# to be added?

# struct theme

# struct scale

# struct coords

