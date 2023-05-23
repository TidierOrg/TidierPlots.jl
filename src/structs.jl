struct Geom
    aes::Dict
    args::Dict
    data::Layer
    visual::Layer
    analysis::Layer
    required_aes::AbstractArray
    optional_aes::Dict
end

struct GGOptions
    values::Dict 
end

struct GGPlot
    geoms::AbstractArray
    default_aes::Dict
    data::Layer
    labs::GGOptions
    axis::NamedTuple
end



# to be added?

# struct scale

# struct coords

