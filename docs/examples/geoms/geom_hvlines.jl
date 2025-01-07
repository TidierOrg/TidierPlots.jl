using TidierPlots
using DataFrames

# Plot only a single y-intercept
ggplot() + geom_hline(yintercept = 3)

# Plot multiple y-intercepts
ggplot() + geom_hline(yintercept = [-1, 4])

# Plot multiple y-intercepts mapped to a column
df = DataFrame(y = rand(4))
ggplot(df, @aes(yintercept = y)) + geom_hline()

# Plot only a single x-intercept
ggplot() + geom_vline(xintercept = 3)

# Plot multiple x-intercepts
ggplot() + geom_vline(xintercept = [-1, 4])

# Plot multiple x-intercepts mapped to a column
df = DataFrame(x = rand(4))
ggplot(df, @aes(xintercept = x)) + geom_vline()
