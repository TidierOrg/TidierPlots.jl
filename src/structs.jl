struct Geom
    aes::Dict
    args::Dict
    required_aes::AbstractArray
    special_aes::Dict
    data::Union{Nothing, DataFrame}
    visual::Symbol
    axis_options::Dict
    aes_function::Function
    column_transformations::Dict
    grouping_aes::Vector{Symbol}
end

struct FacetOptions
    rows::Union{Symbol, Nothing}
    cols::Union{Symbol, Nothing}
    wrap::Union{Symbol, Nothing}
end

struct GGPlot
    geoms::AbstractArray
    default_aes::Dict
    data::Union{Nothing, DataFrame}
    axis_options::Dict
    theme::Attributes
    column_transformations::Dict
    legend_options::Dict
    facet_options::Union{FacetOptions, Nothing}
end

struct Aesthetics
    positional::AbstractArray
    named::Dict
    column_transformations::Dict
end

struct AxisOptions
    opt::Dict{Symbol, Any}
    column_transformations::Dict
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
