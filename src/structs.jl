struct Geom
    aes::Dict
    args::Dict
    required_aes::AbstractArray
    special_aes::Dict
    data::Union{Nothing,DataFrame}
    visual::Symbol
    axis_options::Dict
    pre_function::Function
    post_function::Function
    grouping_aes::Vector{Symbol}
end

struct FacetOptions
    rows::Union{Symbol,Nothing}
    cols::Union{Symbol,Nothing}
    wrap::Union{Symbol,Nothing}
    nrow::Union{Integer,Nothing}
    ncol::Union{Integer,Nothing}
    free_x::Bool
    free_y::Bool
end

struct GGPlot
    geoms::AbstractArray
    default_aes::Dict
    data::Union{Nothing,DataFrame}
    axis_options::Dict
    theme::Makie.Attributes
    legend_options::Dict
    facet_options::Union{FacetOptions,Nothing}
    color_palette::Any
    fill_palette::Any
end

struct Aesthetics
    positional::AbstractArray
    named::Dict
end

struct AxisOptions
    opt::Dict{Symbol,Any}
    color_palette::Any
    fill_palette::Any
    legend_options::Dict
end

struct GGPlotGrid
    plots::Vector{GGPlot}
    grid::Any
end

struct GGPlotGridSpec
    ncol::Int
    nrow::Int
    byrow::Bool
    widths::Vector{Int}
    heights::Vector{Int}
end
