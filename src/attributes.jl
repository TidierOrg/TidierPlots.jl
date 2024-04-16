const _ggplot_to_makie = Dict{String, String}(
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
);


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
