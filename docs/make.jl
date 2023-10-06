push!(LOAD_PATH,"../src/")

using Documenter
using TidierPlots

makedocs(
    sitename = "TidierPlots",
    format = Documenter.HTML(),
    modules = [TidierPlots]
)

deploydocs(
    repo = "github.com/TidierOrg/TidierPlots.jl.git"
)
