@testset "patchwork" verbose = true begin
@testset "horizontal concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m2 = Makie.plot(
        Makie.SpecApi.GridLayout(hcat([test_ax for _ in 1:2]...))
    )
    m3 = Makie.plot(
        Makie.SpecApi.GridLayout(hcat([test_ax for _ in 1:3]...))
    )

    @test plot_images_equal(t | t, m2)
    @test plot_images_equal(t + t, m2)
    @test plot_images_equal(|(t, t, t), m3)
    @test plot_images_equal(t + t + t, m3)
end

@testset "vertical concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m2 = Makie.plot(
        Makie.SpecApi.GridLayout(vcat([test_ax for _ in 1:2]...))
    )
    m3 = Makie.plot(
        Makie.SpecApi.GridLayout(vcat([test_ax for _ in 1:3]...))
    )

    @test plot_images_equal(t / t, m2)
    @test plot_images_equal(/(t, t, t), m3)
end

@testset "grid concatenation" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]
            )
    m21 = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.GridLayout([test_ax test_ax]),
            Makie.SpecApi.GridLayout([test_ax])
        )
    )

    @test plot_images_equal((t | t) / t, m21)
end

@testset "plot layout organization" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    t2 = ggplot(penguins) +
        geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
                )]
            )
    test_ax2 = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_depth_mm, penguins.bill_length_mm
                )]
            )
    # 2x2 grid
    m22 = Makie.plot(
        Makie.SpecApi.GridLayout([
            test_ax test_ax2;
            test_ax test_ax2
            ],
        )
    )
    @test plot_images_equal(t + t2 + t + t2 + plot_layout(), m22)
    @test plot_images_equal(t + t2 + t + t2 + plot_layout(;ncol=2,nrow=2), m22)
    @test plot_images_equal(t + t + t2 + t2 + plot_layout(;ncol=2,nrow=2,byrow=true), m22)
    @test plot_images_equal(t + t2 + t + t2 + plot_layout(;ncol=2,nrow=0), m22)

    # 2x2 grid (missing bottom right)
    m21 = Makie.plot(
        Makie.SpecApi.GridLayout([
                (1,1) => test_ax,
                (1,2) => test_ax2,
                (2,1) => test_ax
            ]
        )
    )
    @test plot_images_equal(t + t2 + t + plot_layout(nrow=2,ncol=2), m21)
    @test plot_images_equal(t + t2 + t + plot_layout(nrow=2), m21)
    @test plot_images_equal(t + t2 + t + plot_layout(), m21)

    # 1x3 grid
    m13 = Makie.plot(
        Makie.SpecApi.GridLayout([
                (1,1) => test_ax,
                (1,2) => test_ax,
                (1,3) => test_ax
            ]
        )
    )
    @test plot_images_equal(t + t + t + plot_layout(;nrow=1), m13)
end

@testset "plot layout sizes" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    t2 = ggplot(penguins) +
        geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
                )]
            )
    test_ax2 = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_depth_mm, penguins.bill_length_mm
                )]
            )
    # 2x2 grid (variable columns widths)
    m22c = Makie.plot(
        Makie.SpecApi.GridLayout([
            test_ax test_ax2;
            test_ax test_ax2
            ],
            colsizes = [Relative(1/3), Relative(2/3)]
        )
    )
    @test plot_images_equal(t + t2 + t + t2 + plot_layout(;widths=[1,2]), m22c)

    # 2x2 grid (missing bottom right)
    m21 = Makie.plot(
        Makie.SpecApi.GridLayout([
                (1,1) => test_ax,
                (1,2) => test_ax2,
                (2,1) => test_ax
            ],
            colsizes = [Relative(1/3), Relative(2/3)]
        )
    )
    @test plot_images_equal(t + t2 + t + plot_layout(;widths=[1,2]), m21)

    # 2x2 grid (variable row heights)
    m22r = Makie.plot(
        Makie.SpecApi.GridLayout([
            test_ax test_ax2;
            test_ax test_ax2
            ],
            rowsizes = [Relative(1/3), Relative(2/3)]
        )
    )
    @test plot_images_equal(t + t2 + t + t2 + plot_layout(;heights=[1,2]), m22r)

    # 1x3 grid
    m13 = Makie.plot(
        Makie.SpecApi.GridLayout([
                (1,1) => test_ax,
                (1,2) => test_ax,
                (1,3) => test_ax
            ],
            colsizes = [Relative(1/6), Relative(2/6), Relative(3/6)]
        )
    )
    @test plot_images_equal(t + t + t + plot_layout(;nrow=1, widths=[1,2,3]), m13)

    # 2x3 grid variable height and width
    m23 = Makie.plot(
        Makie.SpecApi.GridLayout([
                (1,1) => test_ax,
                (1,2) => test_ax,
                (1,3) => test_ax,
                (2,1) => test_ax2,
                (2,2) => test_ax2,
                (2,3) => test_ax2
            ],
            colsizes = [Relative(1/6), Relative(2/6), Relative(3/6)],
            rowsizes = [Relative(1/5), Relative(4/5)]
        )
    )
    @test plot_images_equal(t + t + t + t2 + t2 + t2 + plot_layout(;nrow=2, widths=[1,2,3], heights=[1,4]), m23)
end

@testset "plot layout grids" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
    t2 = ggplot(penguins) +
        geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
    test_ax = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
                )]
            )
    test_ax2 = Makie.SpecApi.Axis(
                plots = [Makie.PlotSpec(
                    :Scatter, penguins.bill_depth_mm, penguins.bill_length_mm
                )]
            )
    m22c = Makie.plot(
        Makie.SpecApi.GridLayout([
            Makie.SpecApi.GridLayout([test_ax test_ax]) test_ax2;
            test_ax test_ax2
            ],
            colsizes = [Relative(1/3), Relative(2/3)]
        )
    )
    @test plot_images_equal((t | t) + t2 + t + t2 + plot_layout(;widths=[1,2]), m22c)
end
end
