@testset verbose = true "geoms" begin

    @testset "geom_point" begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm)
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
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
                    plots = [
                        Makie.PlotSpec(
                            :BarPlot,
                            penguins_count.count)
                    ]; xticks = (1:3, penguins_count.species)
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
                    plots = [
                        Makie.PlotSpec(
                            :BarPlot,
                            penguins_count.count)
                    ]; xticks = (1:3, penguins_count.species)
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
                    plots = [
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
                    plots = [
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
        df = DataFrame(x = xs, y = sin.(xs))

        perm = sortperm(df.x)

        t = ggplot(df, @aes(x = x, y = y)) + geom_step()

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
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
                    plots = [
                        Makie.PlotSpec(
                            :BoxPlot,
                            levelcode.(cat_array),
                            penguins.bill_length_mm)
                    ]; xticks = (unique(levelcode.(cat_array)),
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
                    plots = [
                        Makie.PlotSpec(
                            :Violin,
                            levelcode.(cat_array),
                            penguins.bill_length_mm)
                    ]; xticks = (unique(levelcode.(cat_array)),
                                 unique(cat_array))
                )
            )
        )

        @test plot_images_equal(t, m)

        colours = [
            RGB(0/255, 114/255, 178/255), # blue
            RGB(230/255, 159/255, 0/255), # orange
            RGB(0/255, 158/255, 115/255), # green
            RGB(204/255, 121/255, 167/255), # reddish purple
            RGB(86/255, 180/255, 233/255), # sky blue
            RGB(213/255, 94/255, 0/255), # vermillion
            RGB(240/255, 228/255, 66/255), # yellow
        ]

        t = ggplot(penguins) +
            geom_violin(aes(x = :species, y = :bill_length_mm, color = :species)) + scale_color_manual(values = colours)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                        :Violin,
                        levelcode.(cat_array),
                        penguins.bill_length_mm;
                        color = (x -> colours[x]).(levelcode.(cat_array))
                    )]; xticks = (unique(levelcode.(cat_array)),
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
                    plots = [
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
        t = ggplot(penguins, @aes(x = body_mass_g, color = species)) +
            geom_density()

        adelie = @filter(penguins, species == "Adelie")
        gentoo = @filter(penguins, species == "Gentoo")
        chin = @filter(penguins, species == "Chinstrap")

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Density,
                            adelie.body_mass_g;
                            color =RGB(0/255, 114/255, 178/255)),
                        Makie.PlotSpec(
                            :Density,
                            gentoo.body_mass_g;
                            color =RGB(0/255, 158/255, 115/255)),
                        Makie.PlotSpec(
                            :Density,
                            chin.body_mass_g;
                            color =RGB(230/255, 159/255, 0/255))
                    ]
                )
            )
        )

        @test plot_images_equal(t, m)
    end

    @testset "geom_errorbar" begin
        categories = [1, 2, 3, 4];
        n = length(categories);

        mean_values = rand(n);  # Random mean values for demonstration
        errors = rand(n) / 2;   # Random error values for demonstration

        LowerBound = mean_values .- errors;
        UpperBound = mean_values .+ errors;

        df_errorbar = DataFrame(
            cat_numeric = categories,
            MeanValue = mean_values,
            LowerBound = LowerBound,
            UpperBound = UpperBound);

        t = ggplot(df_errorbar, @aes(x = cat_numeric, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) +
            geom_point() + # to show the mean value
            geom_errorbar(width = 0.2) # width of the horizontal line at the top and bottom of the error bar

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
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

    end

    @testset "geom_smooth" begin
        t = ggplot(penguins, aes(x = "bill_length_mm", y = "bill_depth_mm")) +
            geom_smooth() + geom_point()

        model = Loess.loess(penguins.bill_length_mm, penguins.bill_depth_mm; span = .75, degree = 2)
        x̂ = range(extrema(penguins.bill_length_mm)..., length=200)
        ŷ = Loess.predict(model, x̂)

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
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

        t = ggplot(penguins, aes(x = "bill_length_mm", y = "bill_depth_mm")) +
            geom_smooth(method = "lm") + geom_point()


        function add_intercept_column(x::AbstractVector{T}) where {T}
            mat = similar(x, float(T), (length(x), 2))
            fill!(view(mat, :, 1), 1)
            copyto!(view(mat, :, 2), x)
            return mat
        end

        lin_model = GLM.lm(add_intercept_column(penguins.bill_length_mm), penguins.bill_depth_mm)
        x̂ = range(extrema(penguins.bill_length_mm)..., length=100)
        pred = DataFrame(GLM.predict(lin_model, add_intercept_column(x̂); interval = :confidence))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
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
            geom_text(aes(x = :bill_length_mm, y = :bill_depth_mm, text = :species))

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Text,
                            penguins.bill_length_mm,
                            penguins.bill_depth_mm;
                            text = String.(penguins.species))
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
                    plots = [
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
                    plots = [
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
