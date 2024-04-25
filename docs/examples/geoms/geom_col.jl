using TidierPlots
using TidierData
using DataFrames
using PalmerPenguins

penguins = dropmissing(DataFrame(PalmerPenguins.load()));

df = @chain penguins begin
    @group_by(species, sex)
    @summarize(mean_bill_length_mm = mean(bill_length_mm))
    @ungroup()
end

#-

ggplot(df, @aes(x = species, y = mean_bill_length_mm)) +
    geom_col()

# dodge using the group and position arguments
ggplot(df, @aes(x = species, y = mean_bill_length_mm, group = sex)) +
    geom_col(position="dodge")

# dodge using the dodge aesthetic
ggplot(df, @aes(x = species, y = mean_bill_length_mm, dodge = sex)) +
    geom_col()

# color based on grouping variable
ggplot(df, @aes(x = species, y = mean_bill_length_mm, color = sex)) +
    geom_col()
