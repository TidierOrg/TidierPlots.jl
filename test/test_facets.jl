@testset "facets" begin
    @test_nowarn ggplot(penguins) + geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm)) + facet_wrap(:species)
end
