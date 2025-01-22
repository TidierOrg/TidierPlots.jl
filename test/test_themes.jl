@testset "themes" begin
    invis = TidierPlots.theme(background = :transparent)
    @test invis.opt[:background] == :transparent
end
