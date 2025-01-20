@testset "facets" begin
    @test_nowarn ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm)) +
        facet_wrap(:species)

    @test_nowarn ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm)) +
        facet_wrap(facets = :species)

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm))
        facet_wrap(facets = :species)
    end

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm))
        facet_grid(rows = :species, cols = :sex)
    end

    @test_throws ArgumentError ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm)) +
        facet_wrap(:species, :sex)

    @test_throws ArgumentError facet_grid(:col1)
    fg = facet_grid(rows = :col1, cols = :col2)
    @test fg.cols == :col2
    @test fg.rows == :col1

    fg = facet_grid(rows = :col1, cols = :col2, scales = "free_x")
    @test fg.free_x
    @test !fg.free_y

    fg = facet_grid(rows = :col1, cols = :col2, scales = "free_y")
    @test fg.free_y
    @test !fg.free_x

    fg = facet_grid(rows = :col1, cols = :col2, scales = "free")
    @test fg.free_x
    @test fg.free_y

    fw = facet_wrap(:col1, scales = "free_x")
    @test fw.free_x
    @test !fw.free_y

    fw = facet_wrap(:col1, scales = "free_y")
    @test fw.free_y
    @test !fw.free_x

    fw = facet_wrap(:col1, scales = "free")
    @test fw.free_x
    @test fw.free_y

    p, b, l = TidierPlots.position_facets(["a", "b"])
    @test p["a"] == (1, 1)
    @test p["b"] == (1, 2)
    @test haskey(b, (1, 2, Top()))
    @test haskey(b, (1, 1, Top()))
    @test haskey(l, (1, 2, Top()))
    @test haskey(l, (1, 1, Top()))
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], cols = nothing)
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], rows = 1 cols = 1)

end
