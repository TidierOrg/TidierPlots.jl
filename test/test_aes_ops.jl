@testset verbose = true "aes operations" begin

    @testset "addition" begin
        t = ggplot(penguins) +
            geom_point(aes(x = :bill_length_mm => (x -> x .+ 10),
                           y = :bill_depth_mm (y -> y .+ 20)))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm + 10,
                                    y = bill_depth_mm + 20))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .+ 10,
                            penguins.bill_depth_mm .+ 20)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)

        t = ggplot(penguins) +
            geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) -> x .+ y), y = :bill_depth_mm))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm + bill_depth_mm,
                                    y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .+ penguins.bill_depth_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

    @testset "subtraction" begin
        t = ggplot(penguins) +
            geom_point(aes(x = :bill_length_mm => (x -> x .- 10),
                           y = :bill_depth_mm (y -> y .- 20)))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm - 10,
                                    y = bill_depth_mm - 20))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .- 10,
                            penguins.bill_depth_mm .- 20)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)

        t = ggplot(penguins) +
            geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) -> x .- y), y = :bill_depth_mm))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm - bill_depth_mm,
                                    y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .- penguins.bill_depth_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

    @testset "multiplication" begin
        t = ggplot(penguins) +
            geom_point(aes(x = :bill_length_mm => (x -> x .* 10),
                           y = :bill_depth_mm => (y -> y .* 20)))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm * 10,
                                    y = bill_depth_mm * 20))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .* 10,
                            penguins.bill_depth_mm .* 20)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)

        t = ggplot(penguins) +
            geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) -> x .* y), y = :bill_depth_mm))

        tm = ggplot(penguins) +
                geom_point(@aes(x = bill_length_mm * bill_depth_mm, y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm .* penguins.bill_depth_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

    @testset "division" begin
        t = ggplot(penguins) +
            geom_point(aes(x = :bill_length_mm => (x -> x ./ 10),
                           y = :bill_depth_mm => (y -> y ./ 20)))

        tm = ggplot(penguins) +
                    geom_point(@aes(x = bill_length_mm / 10,
                                    y = bill_depth_mm / 20))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm ./ 10,
                            penguins.bill_depth_mm ./ 20)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)

        t = ggplot(penguins) +
            geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) -> x ./ y), y = :bill_depth_mm))

        tm = ggplot(penguins) +
                geom_point(@aes(x = bill_length_mm / bill_depth_mm, y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm ./ penguins.bill_depth_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

    @testset "one col function" begin
        my_func(x) = x ./ 10

        t = ggplot(penguins) +
            geom_point(aes(x = :bill_length_mm => my_func, y = :bill_depth_mm))

        tm = ggplot(penguins) +
            geom_point(@aes(x = my_func(bill_length_mm), y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm ./ 10,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

    @testset "two col function" begin
        my_func(x, y) = x ./ y

        t = ggplot(penguins) +
            geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => my_func, y = :bill_depth_mm))

        tm = ggplot(penguins) +
            geom_point(aes(my_func(bill_length_mm, bill_depth_mm), y = :bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm ./ penguins.bill_depth_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(tm, m)
    end

end
