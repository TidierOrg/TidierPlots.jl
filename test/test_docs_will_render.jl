@testset "docs-render" verbose = true begin
    # Additional imports for docs tests
    using Statistics
    using RDatasets

    @testset "geom_bar" begin
        # Basic bar chart
        @test plot_will_render(ggplot(penguins, @aes(x = species)) + geom_bar())

        # Horizontal bar chart
        @test plot_will_render(ggplot(penguins, @aes(y = species)) + geom_bar())

        # Stacked bar chart with fill
        @test plot_will_render(ggplot(penguins, @aes(x = species, fill = sex)) + geom_bar())

        # Dodged bar chart with position
        @test plot_will_render(ggplot(penguins, @aes(x = species, fill = sex)) +
            geom_bar(position = "dodge"))

        # Dodge aesthetic
        @test plot_will_render(ggplot(penguins, @aes(x = species, dodge = sex)) +
            geom_bar())

        # Customized appearance
        @test plot_will_render(ggplot(penguins, @aes(x = species, fill = sex)) +
            geom_bar(strokecolor = :black, strokewidth = 1))

        # Gap adjustment
        @test plot_will_render(ggplot(penguins, @aes(x = species)) + geom_bar(gap = 0.5))
    end

    @testset "geom_boxplot" begin
        # Basic boxplot
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_boxplot())

        # Horizontal boxplot
        @test plot_will_render(ggplot(penguins, @aes(y = species, x = bill_length_mm)) +
            geom_boxplot())

        # Grouped boxplot with fill
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = sex)) +
            geom_boxplot())

        # With notches
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_boxplot(show_notch = true, notchwidth = 0.5))

        # Customized appearance
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_boxplot(color = :steelblue))

        # Combined with points
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_boxplot() +
            geom_point(@aes(color = sex)))
    end

    @testset "geom_col" begin
        df = @chain penguins begin
            @group_by(species, sex)
            @summarize(mean_bill_length_mm = mean(bill_length_mm))
            @ungroup()
        end

        # Basic column chart
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm)) + geom_col())

        # Stacked with fill
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, fill = sex)) +
            geom_col())

        # Dodged with group and position
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, group = sex)) +
            geom_col(position = "dodge"))

        # Dodge aesthetic
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, dodge = sex)) +
            geom_col())

        # Direction argument
        df_single = @chain penguins begin
            @group_by(species)
            @summarize(mean_bill_length_mm = mean(bill_length_mm))
        end
        @test plot_will_render(ggplot(df_single, @aes(x = species, y = mean_bill_length_mm)) +
            geom_col(direction = :x))
    end

    @testset "geom_density" begin
        # Basic density
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) + geom_density())

        # Customized with stroke
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_density(color = :steelblue, strokecolor = :black, stroke = 2))

        # Grouped with fill
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
            geom_density())

        # With stroke color on outlines
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
            geom_density(strokecolor = :black, stroke = 1))

        # Stroke color aesthetic
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, strokecolor = species)) +
            geom_density(stroke = 2))

        # Combined with histogram
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(normalization = :pdf) +
            geom_density(strokecolor = :red, stroke = 2))

        # With facets
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, fill = sex)) +
            geom_density() +
            facet_wrap(:species))
    end

    @testset "geom_errorbar" begin
        # Create summary data with confidence intervals
        df = @chain penguins begin
            @group_by(species)
            @summarize(
                mean_bill = mean(bill_length_mm),
                se_bill = std(bill_length_mm) / sqrt(n())
            )
            @mutate(
                lower = mean_bill - 1.96 * se_bill,
                upper = mean_bill + 1.96 * se_bill
            )
        end

        # Basic error bars
        @test plot_will_render(ggplot(df, @aes(x = species, ymin = lower, ymax = upper)) +
            geom_errorbar(linewidth = 2))

        # With whisker caps
        @test plot_will_render(ggplot(df, @aes(x = species, ymin = lower, ymax = upper)) +
            geom_errorbar(linewidth = 2, whiskerwidth = 20))

        # Combined with points
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill, ymin = lower, ymax = upper)) +
            geom_errorbar(linewidth = 1) +
            geom_point(size = 15))

        # Combined with bar chart
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill, ymin = lower, ymax = upper)) +
            geom_col() +
            geom_errorbar(linewidth = 2))

        # Horizontal error bars
        @test plot_will_render(ggplot(df, @aes(y = species, xmin = lower, xmax = upper)) +
            geom_errorbarh(linewidth = 2))

        # Custom error bar data
        df_custom = DataFrame(
            trt   = [1, 1, 2, 2],
            resp  = [1, 5, 3, 4],
            group = ["A", "B", "A", "B"],
            lower = [0.8, 4.6, 2.4, 3.6],
            upper = [1.1, 5.3, 3.3, 4.2]
        )

        @test plot_will_render(ggplot(df_custom, @aes(x = trt, y = resp, ymin = lower, ymax = upper, color = group)) +
            geom_errorbar(linewidth = 2) +
            geom_point(size = 15))
    end

    @testset "geom_histogram" begin
        # Basic histogram
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) + geom_histogram())

        # Different bin counts
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(bins = 20))

        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(bins = 50))

        # With binwidth
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(binwidth = 2))

        # Probability normalization
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(normalization = :probability, bins = 20))

        # Customized appearance
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(bins = 25, color = :steelblue, strokecolor = :black))

        # Grouped by color
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, color = species)) +
            geom_histogram(bins = 20))

        # Combined with density
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(normalization = :pdf, bins = 20) +
            geom_density(strokecolor = :red, stroke = 2))

        # With facets
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(bins = 15) +
            facet_wrap(:species))
    end

    @testset "geom_hvline" begin
        # Basic horizontal line
        @test plot_will_render(ggplot() + geom_hline(yintercept = 3))

        # With points
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point() +
            geom_hline(yintercept = 17, color = :red, linewidth = 2))

        # Multiple horizontal lines
        @test plot_will_render(ggplot() + geom_hline(yintercept = [-1, 0, 1, 4], linewidth = 1))

        # yintercept mapped to data
        df = DataFrame(y = [1, 2, 3, 4])
        @test plot_will_render(ggplot(df, @aes(yintercept = y)) +
            geom_hline(color = :steelblue, linewidth = 2))

        # Basic vertical line
        @test plot_will_render(ggplot() + geom_vline(xintercept = 3))

        # Multiple vertical lines
        @test plot_will_render(ggplot() + geom_vline(xintercept = [-1, 0, 4], color = :purple, linewidth = 1))

        # xintercept mapped to data
        df = DataFrame(x = [1, 2, 3, 4])
        @test plot_will_render(ggplot(df, @aes(xintercept = x)) +
            geom_vline(color = :orange, linewidth = 2))
    end

    @testset "geom_lines" begin
        economics = dataset("ggplot2", "economics")

        # Basic time series
        @test plot_will_render(ggplot(economics, @aes(x = Date, y = Unemploy)) + geom_line())

        # Customized line
        @test plot_will_render(ggplot(economics, @aes(x = Date, y = Unemploy)) +
            geom_line(color = :steelblue, linewidth = 2))

        # Multiple line layers
        @test plot_will_render(ggplot(economics) +
            geom_line(aes(x = :Date, y = :Unemploy), color = :blue) +
            geom_line(aes(x = :Date, y = :Pop), color = :red))

        # Line styles
        xs = range(0, 2pi, length = 50)
        df = DataFrame(x = xs, y = sin.(xs))
        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) +
            geom_line(linestyle = :dash, linewidth = 2))

        # geom_path
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_path())

        # Spiral with geom_path
        t = range(0, 4pi, length = 100)
        spiral = DataFrame(x = t .* cos.(t), y = t .* sin.(t))
        @test plot_will_render(ggplot(spiral, @aes(x = x, y = y)) + geom_path(linewidth = 2))

        # geom_step
        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) + geom_step())

        # Line vs step comparison
        df_step = DataFrame(x = 1:10, y = cumsum(rand(10)))
        @test plot_will_render(ggplot(df_step, @aes(x = x, y = y)) +
            geom_line(color = :blue) +
            geom_step(color = :red))

        # Line with points
        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) +
            geom_line(color = :steelblue, linewidth = 1) +
            geom_point(color = :steelblue, size = 10))

        # Group aesthetic
        df_groups = DataFrame(
            x = repeat(1:5, 3),
            y = rand(15),
            group = repeat(["A", "B", "C"], inner = 5)
        )
        @test plot_will_render(ggplot(df_groups, @aes(x = x, y = y, color = group)) +
            geom_line(linewidth = 2) +
            geom_point(size = 10))
    end

    @testset "geom_point" begin
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point())
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point(@aes(color = sex), size=20, stroke=1))
    end

    @testset "geom_smooth" begin
        # Basic LOESS
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point() +
            geom_smooth())

        # With generated data
        xs = range(0, 2pi, length = 50)
        ys = sin.(xs) .+ randn(length(xs)) * 0.3
        df = DataFrame(x = xs, y = ys)
        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) +
            geom_point() +
            geom_smooth())

        # Linear regression
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point() +
            geom_smooth(method = "lm"))

        # Customized appearance
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point() +
            geom_smooth(color = :red, linewidth = 3))

        # Grouped by color
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
            geom_point() +
            geom_smooth())

        # Linear regression by group
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
            geom_point() +
            geom_smooth(method = "lm"))

        # With facets
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point() +
            geom_smooth(method = "lm") +
            facet_wrap(:species))

        # Noisy data
        noisy_df = DataFrame(
            x = 1:100,
            y = sin.((1:100) ./ 10) .+ randn(100) .* 0.5
        )
        @test plot_will_render(ggplot(noisy_df, @aes(x = x, y = y)) +
            geom_point() +
            geom_smooth(color = :red, linewidth = 2))
    end

    @testset "geom_text" begin
        df = DataFrame(
            x = [1, 1, 2, 2],
            y = [1, 2, 1, 2],
            t = ["A", "B", "C", "D"]
        )

        # Basic text
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t)) + geom_text())

        # Colored text
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t, color = t)) + geom_text())

        # Combined with points
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, color = t)) +
            geom_point(size = 20) +
            geom_text(@aes(text = t), fontsize = 24, align = (:left, :bottom)) +
            lims(x = (0, 3), y = (0, 3)))

        # Font styling
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t)) +
            geom_text(fontsize = 30, font = :bold, color = :steelblue))

        # Text alignment
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t)) +
            geom_point(size = 15) +
            geom_text(fontsize = 20, align = (:center, :bottom)) +
            lims(x = (0.5, 2.5), y = (0.5, 2.5)))

        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t)) +
            geom_point(size = 15) +
            geom_text(fontsize = 20, align = (:left, :center)) +
            lims(x = (0.5, 2.5), y = (0.5, 2.5)))

        # Labeling real data
        species_centroids = @chain penguins begin
            @group_by(species)
            @summarize(
                bill_length_mm = mean(bill_length_mm),
                bill_depth_mm = mean(bill_depth_mm)
            )
        end

        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point(@aes(color = species)) +
            geom_text(data = species_centroids, @aes(text = species),
                fontsize = 20, font = :bold))

        # Rotated text
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t)) +
            geom_text(fontsize = 30, rotation = pi/4))

        # geom_label
        @test plot_will_render(ggplot(df, @aes(x = x, y = y, text = t, color = t)) +
            geom_label(fontsize = 24))

        @test plot_will_render(ggplot(df, @aes(x = x, y = y, color = t)) +
            geom_label(@aes(text = t), fontsize = 24, align = (:left, :bottom), font = :bold) +
            geom_point() +
            lims(x = (0, 3), y = (0, 3)))

        # Annotating bar charts
        summary_df = @chain penguins begin
            @group_by(species)
            @summarize(count = n())
        end

        @test plot_will_render(ggplot(summary_df, @aes(x = species, y = count)) +
            geom_col() +
            geom_text(@aes(text = count), fontsize = 20, align = (:center, :bottom)))
    end

    @testset "geom_tile" begin
        # Basic heatmap
        df_simple = DataFrame(
            x = repeat(1:5, inner = 5),
            y = repeat(1:5, outer = 5),
            z = rand(25)
        )
        @test plot_will_render(ggplot(df_simple, @aes(x = x, y = y, z = z)) + geom_tile())

        # Mandelbrot set
        function mandelbrot(x, y)
            z = c = x + y*im
            for i in 1:30.0
                abs(z) > 2 && return i
                z = z^2 + c
            end
            return 0
        end

        xs = -2:0.05:1  # Reduced resolution for faster tests
        ys = -1.1:0.05:1.1
        xys = Iterators.product(xs, ys) |> collect |> vec
        zs = map(xy -> mandelbrot(xy[1], xy[2]), xys)

        df_mandelbrot = DataFrame(
            x = first.(xys),
            y = last.(xys),
            z = zs
        )
        @test plot_will_render(ggplot(df_mandelbrot, @aes(x = x, y = y, z = z)) + geom_tile())

        # Correlation matrix
        numeric_cols = [:bill_length_mm, :bill_depth_mm, :flipper_length_mm, :body_mass_g]
        cor_matrix = cor(Matrix(penguins[:, numeric_cols]))
        n = length(numeric_cols)
        cor_df = DataFrame(
            x = repeat(1:n, inner = n),
            y = repeat(1:n, outer = n),
            z = vec(cor_matrix)
        )
        @test plot_will_render(ggplot(cor_df, @aes(x = x, y = y, z = z)) + geom_tile())

        # Custom colormaps
        df_gradient = DataFrame(
            x = repeat(1:10, inner = 10),
            y = repeat(1:10, outer = 10),
            z = [(i + j) / 20 for i in 1:10 for j in 1:10]
        )
        @test plot_will_render(ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
            geom_tile(colormap = :viridis))

        @test plot_will_render(ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
            geom_tile(colormap = :thermal))

        @test plot_will_render(ggplot(df_gradient, @aes(x = x, y = y, z = z)) +
            geom_tile(colormap = :RdBu))

        # Sine wave pattern
        xs_sine = range(0, 4pi, length = 25)  # Reduced resolution for faster tests
        ys_sine = range(0, 4pi, length = 25)
        xys_sine = Iterators.product(xs_sine, ys_sine) |> collect |> vec

        df_sine = DataFrame(
            x = first.(xys_sine),
            y = last.(xys_sine),
            z = [sin(x) * cos(y) for (x, y) in xys_sine]
        )
        @test plot_will_render(ggplot(df_sine, @aes(x = x, y = y, z = z)) +
            geom_tile(colormap = :coolwarm))

        # Checkerboard
        checkerboard = DataFrame(
            x = repeat(1:8, inner = 8),
            y = repeat(1:8, outer = 8),
            z = [mod(i + j, 2) for i in 1:8 for j in 1:8]
        )
        @test plot_will_render(ggplot(checkerboard, @aes(x = x, y = y, z = z)) +
            geom_tile(colormap = :grays))
    end

    @testset "geom_violin" begin
        # Basic violin
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin())

        # Horizontal orientation
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin(orientation = :horizontal))

        # Grouped with fill
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = sex)) +
            geom_violin())

        # Customized appearance
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin(color = :steelblue))

        # Fill by species
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = species)) +
            geom_violin())

        # Combined with boxplot
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin() +
            geom_boxplot(width = 0.2))

        # With points
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin() +
            geom_point())

        # With jitter
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin() +
            geom_jitter(width = 0.1))

        # Other variables
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = flipper_length_mm)) +
            geom_violin() +
            labs(title = "Flipper Length by Species"))

        @test plot_will_render(ggplot(penguins, @aes(x = species, y = body_mass_g)) +
            geom_violin() +
            labs(title = "Body Mass by Species"))

        # With facets
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin() +
            facet_wrap(:sex))

        # Comparison with density
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, fill = species)) +
            geom_density())

        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm, fill = species)) +
            geom_violin())
    end
end
