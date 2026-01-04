using Documenter, DocumenterMarkdown
using TidierPlots

makedocs(
    modules=[TidierPlots],
    clean=true,
    doctest=true,
    warnonly=true,
    sitename="TidierPlots.jl",
    authors="Randall Boyes et al.",
    checkdocs=:all,
    format=Markdown(),
    draft=false,
    build=joinpath(@__DIR__, "docs")
)

deploydocs(; devurl="latest", repo="github.com/TidierOrg/TidierPlots.jl", push_preview=true,
    deps=Deps.pip("mkdocs", "pygments", "python-markdown-math", "mkdocs-material",
        "pymdown-extensions", "mkdocstrings", "mknotebooks",
        "pytkdocs_tweaks", "mkdocs_include_exclude_files", "jinja2", "mkdocs-video"),
    make=() -> run(`mkdocs build`), target="site", devbranch="main")
