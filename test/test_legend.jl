@testset "legend operations" begin
    g = ggplot() + guides(color = "legend")
    @test g.legend_options[:color][:guide] == :legend
end
