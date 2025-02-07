@testset "facets" begin
    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species)

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species)

    @test plot_images_equal(t1, t2)

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm))
        facet_wrap(facets=:species)
    end

    @test_nowarn @chain ggplot(penguins) begin
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm))
        facet_grid(rows=:species, cols=:sex)
    end

    @test_throws ArgumentError ggplot(penguins) +
                               geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
                               facet_wrap(:species, :sex)

    @test_throws ArgumentError facet_grid(:col1)
    fg = facet_grid(rows=:col1, cols=:col2)

    @test fg.cols == :col2
    @test fg.rows == :col1

    fg = facet_grid(rows=:col1, cols=:col2, scales="free_x")
    @test fg.free_x
    @test !fg.free_y

    fg = facet_grid(rows=:col1, cols=:col2, scales="free_y")
    @test fg.free_y
    @test !fg.free_x

    fg = facet_grid(rows=:col1, cols=:col2, scales="free")
    @test fg.free_x
    @test fg.free_y

    fw = facet_wrap(:col1, scales="free_x")
    @test fw.free_x
    @test !fw.free_y

    fw = facet_wrap(:col1, scales="free_y")
    @test fw.free_y
    @test !fw.free_x

    fw = facet_wrap(:col1, scales="free")
    @test fw.free_x
    @test fw.free_y

    p, b, l = TidierPlots.position_facets(["a", "b"])
    @test p["a"] == (1, 1)
    @test p["b"] == (1, 2)
    @test haskey(b, (1, 2, Top()))
    @test haskey(b, (1, 1, Top()))
    @test haskey(l, (1, 2, Top()))
    @test haskey(l, (1, 1, Top()))
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], nothing, nothing)
    @test_throws ArgumentError TidierPlots.position_facets(["a", "b"], 1, 1)

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, 1, :top)
    @test p["b"] == (2, 1)
    @test length(l) == 1

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, 1, :none)
    @test length(l) == 0

    p, b, l = TidierPlots.position_facets(["a", "b"], 2, nothing, :none)
    @test length(l) == 0

    # test that non-numeric automatic limit scaling is working with facets

    t1 = ggplot(penguins) +
        geom_bar(aes(x=:sex)) +
        facet_wrap(:sex)

    t2 = ggplot(penguins) +
        geom_bar(aes(x=:sex)) +
        facet_wrap(facets = :sex)

    @test plot_images_equal(t1, t2)

    # free_x and free_y

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free_x")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free_x")

    @test plot_images_equal(t1, t2)

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free_y")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free_y")

    @test plot_images_equal(t1, t2)

    t1 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(:species, scales="free")

    t2 = ggplot(penguins) +
        geom_point(aes(x=:bill_length_mm, y=:bill_depth_mm)) +
        facet_wrap(facets=:species, scales="free")

    @test plot_images_equal(t1, t2)

    fg = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm)) +
        facet_grid(rows = :sex, cols = :species, labels = :topright)

    @test plot_will_render(fg)

    p, b, l = TidierPlots.position_facets([("a", "b"), ("c", "d")])

    @test p[("a", "b")] == (1,1)
    @test p[("c", "b")] == (2,1)
    @test p[("c", "d")] == (2,2)
    @test p[("a", "d")] == (1,2)

    p, b, l = TidierPlots.position_facets([("a", "b"), ("c", "d")], nothing, nothing, :bottomleft)
    x = l[(2,1,Makie.Left())]

    @test x.kwargs[:text] == "c"

end
