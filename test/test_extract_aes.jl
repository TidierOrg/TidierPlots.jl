@testset "extract aes" begin
    @test_throws ArgumentError TidierPlots.extract_aes([aes(:x)], Dict())

    x_extractor = TidierPlots.make_aes_extractor(["x"])

    @test_throws ArgumentError x_extractor([aes(:col1, x = :col2)], Dict())

    pos = x_extractor([aes(:col1)], Dict())
    named = x_extractor([aes(x = :col1)], Dict())

    @test pos[1][:x] == named[1][:x]
end
