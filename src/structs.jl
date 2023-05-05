struct geom
    visual::Any
    aes::Dict
    args::Dict
    analysis::Any
    data::Any
    required_aes::AbstractArray
end

struct ggplot
    geoms::AbstractArray
    default_aes::Dict
    data::Any
    axis::NamedTuple
end

# to be added?

# struct theme

# struct scale

# struct coords

