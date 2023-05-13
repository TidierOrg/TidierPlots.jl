struct labs
    values::Dict 
end

struct theme
    values::Dict
end

struct geom
    visual::Any
    aes::Dict
    args::Dict
    analysis::Any
    data::Any
    required_aes::AbstractArray
    optional_aes::Dict
end

struct ggplot
    geoms::AbstractArray
    default_aes::Dict
    data::Any
    labs::labs
    axis::NamedTuple
end

# to be added?

# struct scale

# struct coords

