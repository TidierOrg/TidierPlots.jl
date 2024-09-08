import Base.iterate
import Base.length

Base.iterate(p::TidierPlots.GGPlot) = (p, 1)
Base.iterate(p::TidierPlots.GGPlot, s::Any) = nothing
Base.length(p::TidierPlots.GGPlot) = 1
