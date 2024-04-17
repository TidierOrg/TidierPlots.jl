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


