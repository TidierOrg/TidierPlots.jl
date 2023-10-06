push!(LOAD_PATH,"../src/")

using Pkg
Pkg.activate("..")

using Documenter
using TidierPlots

makedocs(
    sitename = "TidierPlots",
    format = Documenter.HTML(),
    modules = [TidierPlots]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
