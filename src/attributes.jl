const _makie_expected_type = Dict{String, Type}(
    # Generic Attributes
    "depth_shift" => Float32,
    "fxaa" => Bool,
    "inspectable" => Bool,
    "model" => Any,
    "overdraw" => Bool,
    "space" => Symbol,
    "transparency" => Bool,
    "visible" => Bool,

    # Color Attributes
    "alpha" => Real,
    "color" => Any,
    "colormap" => Symbol,
    "colorrange" => Tuple{<:Real, <:Real},
    "colorscale" => Function,
    "highclip" => Any,
    "lowclip" => Any,
    "nan_color" => Any,

    # Line Attributes
    "linestyle" => Symbol,
    "linewidth" => Real,
    "step" => Symbol,

    # Stroke Attributes
    "strokecolor" => Symbol,
    "strokewidth" => Real,
    "strokearound" => Bool,

    # Marker Attributes
    "marker" => Symbol,
    "markersize" => Real,
    "markerspace" => Symbol,
    "glowwidth" => Real,
    "glowcolor" => Symbol,
    "transform_marker" => Bool,

    # Label Attributes
    "label_color" => Symbol,
    "label_font" => Symbol,
    "label_offset" => Real,
    "label_rotation" => Real,
    "label_size" => Real,

    # Text Attributes
    "align" => Any,
    "font" => Any,
    "fontsize" => Real,
    "justification" => Any,
    "text" => Any,
    "word_wrap_width" => Real,

    # Transformations
    "direction" => Symbol,
    "flip" => Bool,
    "orientation" => Symbol,
    "rotation" => Real,

    # BoxPlot/Violin Specific
    "weights" => Any,
    "side" => Symbol,
    "show_notch" => Bool,
    "notchwidth" => Real,
    "show_median" => Bool,
    "range" => Real,
    "whiskerwidth" => Real,
    "show_outliers" => Bool,

    # Density Specific
    "npoints" => Integer,

    # HeatMap Specific
    "interpolate" => Bool,

    # Hist Specific
    "normalization" => Symbol,
    "bins" => Integer,

    # HLines and VLines Specific
    "xmin" => Real,
    "xmax" => Real,
    "ymin" => Real,
    "ymax" => Real,
);

"""
    MakieExpectedTypeDict <: AbstractDict{String, Type}

A dictionary defining the expected types for Makie attributes with the default value `Any`.

The singleton type is [`makie_expected_type`](@ref).

# Examples

```julia-repl
julia> makie_expected_type("marker")
Symbol

julia> makie_expected_type("unknown_attr")
Any

julia> special_aes = Dict("unknown_attr" => Float64);

julia> new_mapping = merge(makie_expected_type, special_aes);

julia> new_mapping("unknown_attr")
Float64

julia> makie_expected_type("unknown_attr")
Any
```
"""
struct MakieExpectedTypeDict <: AbstractDict{String, Type}
    dict::AbstractDict{String, Type}
end

Base.keys(d::MakieExpectedTypeDict) = keys(d.dict)
Base.values(d::MakieExpectedTypeDict) = values(d.dict)
Base.iterate(d::MakieExpectedTypeDict, state=1) = iterate(d.dict, state)
Base.length(d::MakieExpectedTypeDict) = length(d.dict)
Base.get(d::MakieExpectedTypeDict, key, default=Any) = get(d.dict, key, default)
Base.getindex(d::MakieExpectedTypeDict, key) = get(d.dict, key, Any)

(d::MakieExpectedTypeDict)(key::String) = d[key]

function Base.merge(d::MakieExpectedTypeDict, others::AbstractDict{String, Type}...)
    new_dict = merge(d.dict, others...)
    return MakieExpectedTypeDict(new_dict)
end

"""
    makie_expected_type

The singleton instance of type [`MakieExpectedTypeDict`](@ref). b
"""
const makie_expected_type = MakieExpectedTypeDict(_makie_expected_type)



const _ggplot_to_makie_attributes = Dict{String, String}(
    "colour" => "color",
    "shape" => "marker",
    "size" => "markersize",
    "stroke" => "strokewidth",
    "strokecolour" => "strokecolor",
    "linetype" => "linestyle",
    "glow" => "glowwidth",
    "glowcolour" => "glowcolor",
    "errorbar_direction" => "direction",
    "label" => "text",
    "palette" => "colormap"
)

"""
    GGPlotToMakieAttributeDict <: AbstractDict{String, String}

A dictionary defining translations from GGPlot attributes to Makie attributes. Default value
is just the key.

The singleton instance is [`ggplot_to_makie_attribute`](@ref).

# Examples

```julia-repl
julia> ggplot_to_makie_attribute["colour"]
"color"

julia> ggplot_to_makie_attribute["orientation"]
"orientation"
```
"""
struct GGPlotToMakieAttributeDict <: AbstractDict{String, String}
    dict::AbstractDict{String, String}
end

Base.keys(d::GGPlotToMakieAttributeDict) = keys(d.dict)
Base.values(d::GGPlotToMakieAttributeDict) = values(d.dict)
Base.iterate(d::GGPlotToMakieAttributeDict, state=1) = iterate(d.dict, state)
Base.length(d::GGPlotToMakieAttributeDict) = length(d.dict)
Base.get(d::GGPlotToMakieAttributeDict, key, default=key) = get(d.dict, key, default)
Base.getindex(d::GGPlotToMakieAttributeDict, key) = get(d.dict, key, key)

(d::GGPlotToMakieAttributeDict)(key::String) = d[key]

function Base.merge(d::GGPlotToMakieAttributeDict, others::AbstractDict{String, String}...)
    new_dict = merge(d.dict, others...)
    return GGPlotToMakieAttributeDict(new_dict)
end

"""
    ggplot_to_makie_attribute

The singleton instance of type [`GGPlotToMakieAttributeDict`](@ref).
"""
const ggplot_to_makie_attribute = GGPlotToMakieAttributeDict(_ggplot_to_makie_attributes)
