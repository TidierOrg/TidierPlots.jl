using TidierPlots
using DataFrames

df = DataFrame(
    trt   = [1, 1, 2, 2],
    resp  = [1, 5, 3, 4],
    group = [1, 2, 1, 2],
    lower = [0.8, 4.6, 2.4, 3.6],
    upper = [1.1, 5.3, 3.3, 4.2],
)

ggplot(df, @aes(x = trt, ymin = lower, ymax = upper)) +
    geom_errorbar(width=20, linewidth=2)

ggplot(df, @aes(y = trt, xmin = lower, xmax = upper)) +
    geom_errorbarh(width=20, linewidth=2)
