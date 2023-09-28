struct Geom
    aes::Dict
    args::Dict
    data::Layer
    visual::Layer
    analysis::Layer
    required_aes::AbstractArray
    optional_aes::Dict
    axis_options::Dict
end

struct GGPlot
    geoms::AbstractArray
    default_aes::Dict
    data::Layer
    axis_options::Dict
    theme::Attributes
end

struct Aesthetics
    aes::Dict
end