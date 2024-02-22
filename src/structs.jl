struct Geom
    aes::Dict
    args::Dict
    data::DataFrame
    visual::Makie.PlotSpec
    required_aes::AbstractArray
    optional_aes::Dict
    axis_options::Dict
end

struct GGPlot
    geoms::AbstractArray
    default_aes::Dict
    data::DataFrame
    axis_options::Dict
    theme::Attributes
end

struct Aesthetics
    aes::Dict
end