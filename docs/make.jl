using Documenter
using TidierPlots

push!(LOAD_PATH,"../src/")

TidierPlots_set("plot_show", false)
TidierPlots_set("plot_log", false)
TidierPlots_set("plot_pluto", false)
TidierPlots_set("verbose", false)

makedocs(
    modules=[TidierPlots],
    sitename="TidierPlots.jl",
    authors="Randall Boyes et al.",
    format = Documenter.HTML(; size_threshold=10_000_000),
    pages= [
        "Home" => "index.md",
        "Geoms" => [
            "geom_point" => "geoms/geom_point.md",
            "geom_bar" => "geoms/geom_bar.md",
            "geom_boxplot" => "geoms/geom_boxplot.md",
            "geom_col" => "geoms/geom_col.md",
            "geom_density" => "geoms/geom_density.md",
            "geom_errorbar" => "geoms/geom_errorbars.md",
            "geom_histogram" => "geoms/geom_hist.md",
            "geom_hline / geom_vline" => "geoms/geom_hvlines.md",
            "geom_line / geom_path / geom_step" => "geoms/geom_lines.md",
            "geom_rainclouds" => "geoms/geom_rainclouds.md",
            "geom_smooth" => "geoms/geom_smooth.md",
            "geom_text / geom_label" => "geoms/geom_text.md",
            "geom_tile" => "geoms/geom_tile.md",
            "geom_violin" => "geoms/geom_violin.md",
        ],
        "Reference" => "reference.md",
    ];
    remotes=nothing
)

deploydocs(;
    repo="github.com/TidierOrg/TidierPlots.jl",  
    branch = "gh-pages",
    devbranch = "main", 
    push_preview = true,
)
