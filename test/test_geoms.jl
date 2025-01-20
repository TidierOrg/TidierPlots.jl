@testset verbose = true "geoms" begin

    @testset "geom_point" begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

        t2 = ggplot() +
            geom_point(penguins, @aes(x = bill_length_mm, y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(t2, m)

        t3 = ggplot() +
            geom_point(penguins,
                @aes(x = bill_length_mm, y = bill_depth_mm, color = sex))
        t4 = ggplot() +
            geom_point(penguins,
                @aes(x = bill_length_mm, y = bill_depth_mm, fill = sex))

        @test plot_images_equal(t3, t4)

        t5 = ggplot(penguins) +
            geom_point(
                @aes(x = bill_length_mm,
                     y = bill_depth_mm,
                     color = sex,
                     fill = species),
                strokewidth = 1) + guides(color = "none", fill = "none")

        cat_species = CategoricalArrays.CategoricalArray(penguins.species)
        cat_sex = CategoricalArrays.CategoricalArray(penguins.sex)

        m2 = Makie.plot(Makie.SpecApi.GridLayout(Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter,
                penguins.bill_length_mm,
                penguins.bill_depth_mm;
                color = TidierPlots._default_discrete_palette(cat_species),
                strokecolor = TidierPlots._default_discrete_palette(cat_sex),
                strokewidth = 1)
            ]
        )))

        @test plot_images_equal(t5, m2)
    end


    @testset "geom_bar" begin
        t = ggplot(penguins) +
            geom_bar(@aes(x = species))

        penguins_count = @chain penguins begin
            groupby(:species)
            @summarize(count = n())
            @arrange(species)
        end

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :BarPlot,
                            penguins_count.count)
                    ]; xticks=(1:3, penguins_count.species)
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_col" begin
        penguins_count = @chain penguins begin
            groupby(:species)
            @summarize(count = n())
            @arrange(species)
        end

        t = ggplot(penguins_count) +
            geom_col(@aes(x = species, y = count))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :BarPlot,
                            penguins_count.count)
                    ]; xticks=(1:3, penguins_count.species)
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_path" begin
        t = ggplot(penguins) +
            geom_path(@aes(x = bill_length_mm, y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Lines,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_line" begin
        t = ggplot(penguins) +
            geom_line(@aes(x = bill_length_mm, y = bill_depth_mm))

        perm = sortperm(penguins.bill_length_mm)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Lines,
                            penguins.bill_length_mm[perm],
                            penguins.bill_depth_mm[perm])
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_step" begin
        xs = collect(rand(30) * 2pi)
        df = DataFrame(x=xs, y=sin.(xs))

        perm = sortperm(df.x)

        t = ggplot(df, @aes(x = x, y = y)) + geom_step()

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Stairs,
                            df.x[perm],
                            df.y[perm])
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_boxplot" begin
        t = ggplot(penguins) +
            geom_boxplot(@aes(x = species, y = bill_length_mm))

        cat_array = CategoricalArrays.CategoricalArray(penguins.species)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :BoxPlot,
                            levelcode.(cat_array),
                            penguins.bill_length_mm)
                    ]; xticks=(unique(levelcode.(cat_array)),
                        unique(cat_array))
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_violin" begin
        t = ggplot(penguins) +
            geom_violin(@aes(x = species, y = bill_length_mm))

        cat_array = CategoricalArrays.CategoricalArray(penguins.species)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Violin,
                            levelcode.(cat_array),
                            penguins.bill_length_mm)
                    ]; xticks=(unique(levelcode.(cat_array)),
                        unique(cat_array))
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_hist" begin
        t = ggplot(penguins) +
            geom_histogram(@aes(x = bill_length_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Hist,
                            penguins.bill_length_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_density" begin
        t = ggplot(penguins, @aes(x = body_mass_g)) +
            geom_density()

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Density,
                        penguins.body_mass_g)]
            )]
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_errorbar" begin
        categories = [1, 2, 3, 4]
        n = length(categories)

        mean_values = rand(n)  # Random mean values for demonstration
        errors = rand(n) / 2   # Random error values for demonstration

        LowerBound = mean_values .- errors
        UpperBound = mean_values .+ errors

        df_errorbar = DataFrame(
            cat_numeric=categories,
            MeanValue=mean_values,
            LowerBound=LowerBound,
            UpperBound=UpperBound)

        t = ggplot(df_errorbar, @aes(x = cat_numeric, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) +
            geom_point() + # to show the mean value
            geom_errorbar() # width of the horizontal line at the top and bottom of the error bar

        t2 = @chain ggplot(df_errorbar, @aes(x = cat_numeric, y = MeanValue, ymin = LowerBound, ymax = UpperBound))  begin
            geom_point()
            geom_errorbar()
        end

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            df_errorbar.cat_numeric,
                            df_errorbar.MeanValue),
                        Makie.PlotSpec(
                            :Rangebars,
                            df_errorbar.cat_numeric,
                            df_errorbar.LowerBound,
                            df_errorbar.UpperBound)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
        @test plot_images_equal(t2, m)

        t3 = @chain ggplot(df_errorbar, @aes(y = cat_numeric, x = MeanValue, xmin = LowerBound, xmax = UpperBound)) begin
            geom_point()
            geom_errorbarh()
        end

        t4 = ggplot(df_errorbar, @aes(y = cat_numeric, x = MeanValue, xmin = LowerBound, xmax = UpperBound)) +
            geom_point() + # to show the mean value
            geom_errorbarh()

        m2 = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            df_errorbar.MeanValue,
                            df_errorbar.cat_numeric),
                        Makie.PlotSpec(
                            :Rangebars,
                            df_errorbar.cat_numeric,
                            df_errorbar.LowerBound,
                            df_errorbar.UpperBound; direction = :x)
                    ]
                )
            )
        )

        @test plot_images_equal(t3, m2)
        @test plot_images_equal(t4, m2)

    end

    @testset "geom_smooth" begin
        t = ggplot(penguins, aes(x="bill_length_mm", y="bill_depth_mm")) +
            geom_smooth() + geom_point()

        model = Loess.loess(penguins.bill_length_mm, penguins.bill_depth_mm; span=0.75, degree=2)
        x̂ = range(extrema(penguins.bill_length_mm)..., length=200)
        ŷ = Loess.predict(model, x̂)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Lines,
                            x̂,
                            ŷ),
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm
                        )
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)

        t = ggplot(penguins, aes(x="bill_length_mm", y="bill_depth_mm")) +
            geom_smooth(method="lm") + geom_point()


        function add_intercept_column(x::AbstractVector{T}) where {T}
            mat = similar(x, float(T), (length(x), 2))
            fill!(view(mat, :, 1), 1)
            copyto!(view(mat, :, 2), x)
            return mat
        end

        lin_model = GLM.lm(add_intercept_column(penguins.bill_length_mm), penguins.bill_depth_mm)
        x̂ = range(extrema(penguins.bill_length_mm)..., length=100)
        pred = DataFrame(GLM.predict(lin_model, add_intercept_column(x̂); interval=:confidence))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Lines,
                            x̂,
                            pred.prediction),
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm
                        ),
                        Makie.PlotSpec(
                            :Band,
                            x̂,
                            pred.lower,
                            pred.upper
                        )
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)

    end

    @testset "geom_text" begin
        t = ggplot(penguins) +
            geom_text(aes(x=:bill_length_mm, y=:bill_depth_mm, text=:species))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Text,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm;
                            text=String.(penguins.species))
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)

    end

    @testset "geom_hline" begin
        yint = 2.5

        t = ggplot(penguins) +
            geom_hline(yintercept=yint)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :HLines,
                            yint
                        )
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_vline" begin
        xint = 2.5

        t = ggplot() +
            geom_vline(xintercept=xint)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :VLines,
                            xint
                        )
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end
end
