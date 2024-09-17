# these functions only exist to allow broadcasting to work on ggplots

import Base.iterate
import Base.length

Base.iterate(p::TidierPlots.GGPlot) = (p, 1)
Base.iterate(p::TidierPlots.GGPlot, s::Any) = nothing
Base.length(p::TidierPlots.GGPlot) = 1
