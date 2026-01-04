# as issues are resolved, add tests here to make sure they stay fixed
# issue 167 - labs should be able to set legend names

@testitem "issue 167 regression check" begin
    t = ggplot(penguins) + geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm, color=:sex)) + labs(color="Sex") + scale_color_discrete(palette=:julia)
    f = TidierPlots.as_GridLayout(t)
    @test f.content[2][2].content[1][2].kwargs[:entrygroups][1][1] == "Sex" # The legend label should be "Sex"
end
