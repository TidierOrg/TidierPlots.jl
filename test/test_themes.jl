@testset "themes" begin
    invis = theme(background = :transparent)
    @test t.opt[:background] == :transparent
end
