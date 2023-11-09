using TidierPlots
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

# ## @geom_bar, @labs
ggplot(data = penguins) + 
    geom_bar(@aes(x = species)) +
    labs(x = "Species")

ggplot(data = penguins) +
           geom_bar(@aes(x = species, color = island), position = "dodge") +
           labs(x = "Species", y = "Count", color = "Island of Origin")

ggplot(data = penguins) + 
    geom_bar(@aes(x = species, color = island), position = "stack") +
    labs(x = "Species")

# ## geom_point, geom_smooth, theme_dark
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
    geom_point() + 
    geom_smooth(method = "lm") +
    labs(x = "Bill Length (mm)", y = "Bill Width (mm)", 
        title = "Bill Length vs. Bill Width", 
        subtitle = "Using geom_point and geom_smooth") +
    theme_dark()

 ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
    geom_point(shape = diamond, 
            size = 20, 
            stroke = 1, 
            strokecolour = "black",
            alpha = 0.8) +
    labs(x = "Bill Length (mm)", y = "Bill Width (mm)") +
    lims(x = c(40, 60), y = c(15, 20)) +
    theme_minimal()

# ## @scale_x_log10, @scale_y_reverse
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) + 
    geom_point() + 
    geom_smooth(method = "lm") +
    scale_x_log10(name = "Log10 Scaled Bill Length") + 
    scale_y_reverse(name = "Reversed Bill Width")

# ## @geom_path
using MarketData
AAPL = DataFrame(yahoo("AAPL"))
SPX = DataFrame(yahoo("^GSPC"))

ggplot(data = AAPL, @aes(x = timestamp, y = Open)) + 
    geom_path(colour = "blue") + 
    geom_path(data = SPX, colour = "orange") + 
    labs(x = "Date", title = "Historical AAPL and S&P Prices at Open") +
    theme_minimal()

# ## @geom_errorbar
df = DataFrame(
         trt = ["1", "1", "2", "2"],
         resp = [1, 5, 3, 4],
         group = ["1", "2", "1", "2"],
         upper = [1.1, 5.3, 3.3, 4.2],
         lower = [0.8, 4.6, 2.4, 3.6]
       )

p = ggplot(data = df, @aes(x = trt, y = resp, colour = group))

p + geom_errorbar(@aes(ymin = lower, ymax = upper)) + 
    geom_point(@aes(x = trt, y = resp, colour = group))

data(penguins) * Layer(geom_point(aes(x = bill_length_mm, y = bill_depth_mm, color = species))) |> draw