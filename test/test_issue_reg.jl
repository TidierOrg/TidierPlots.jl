@testset "issue regressions" begin
    # as issues are resolved, add tests here to make sure they stay fixed
    # issue 167 - labs should be able to set legend names
    t = ggplot(penguins) + geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm, color=:sex)) + labs(color="Sex") + scale_color_discrete(palette=:julia)
    @test plot_hash(t) == 0x0008001fb023fdff
end
