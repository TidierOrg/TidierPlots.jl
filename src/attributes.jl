const _legend_geom_elements = Dict{String, DataType}(
    "geom_bar" => MarkerElement,
    "geom_col" => MarkerElement,
    "geom_histogram" => MarkerElement,
    "geom_point" => MarkerElement,
    "geom_path" => LineElement,
    "geom_line" => LineElement,
    "geom_step" => LineElement,
    "geom_smooth" => LineElement,
    "geom_errorbar" => LineElement,
    "geom_errorbarh" => LineElement,
    "geom_violin" => MarkerElement,
    "geom_boxplot" => MarkerElement,
    "geom_contour" => LineElement,
    "geom_tile" => MarkerElement,
    "geom_text" => MarkerElement,
    "geom_label" => MarkerElement,
    "geom_density" => MarkerElement,
    "geom_hline" => LineElement,
    "geom_vline" => LineElement
);

const _legend_geom_symbols = Dict{String, Dict}(
    "geom_bar" => Dict(:marker => :rect, :markersize => 12),
    "geom_col" => Dict(:marker => :rect, :markersize => 12),
    "geom_histogram" => Dict(:marker => :rect, :markersize => 12),
    "geom_point" => Dict(:marker => :circle, :markersize => 12),
    "geom_path" => Dict(:linestyle => nothing),
    "geom_line" => Dict(:linestyle => nothing),
    "geom_step" => Dict(:linestyle => nothing),
    "geom_smooth" => Dict(:linestyle => nothing),
    "geom_errorbar" => Dict(:linestyle => nothing),
    "geom_errorbarh" => Dict(:linestyle => nothing),
    "geom_violin" => Dict(:marker => :rect, :markersize => 12),
    "geom_boxplot" => Dict(:marker => :rect, :markersize => 12),
    "geom_contour" => Dict(:linestyle => nothing),
    "geom_tile" => Dict(:marker => :rect, :markersize => 12),
    "geom_text" => Dict(:marker => :x, :markersize => 12),
    "geom_label" => Dict(:marker => :x, :markersize => 12),
    "geom_density" => Dict(:marker => :rect, :markersize => 12),
    "geom_hline" => Dict(:linestyle => nothing),
    "geom_vline" => Dict(:linestyle => nothing)
);

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
    "marker" => Any,
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

