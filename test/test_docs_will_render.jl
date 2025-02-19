@testset "docs-render" verbose = true begin
    @testset "geom_bar" begin
        @test plot_will_render(ggplot(penguins) + geom_bar(@aes(x = species)))
        @test plot_will_render(ggplot(penguins) + geom_bar(@aes(y = species)))
        @test plot_will_render(ggplot(penguins, @aes(x = species, fill=sex)) + geom_bar())
        @test plot_will_render(ggplot(penguins, @aes(x = species, fill=sex, dodge = sex)) + geom_bar())
    end
    @testset "geom_boxplot" begin
        @test plot_will_render(ggplot(penguins, @aes(x=species, y=bill_length_mm)) + geom_boxplot())
        @test plot_will_render(ggplot(penguins, @aes(y=species, x=bill_length_mm)) + geom_boxplot())
        @test plot_will_render(ggplot(penguins,
            @aes(x=species, y=bill_length_mm, fill=sex)) + geom_boxplot())
    end
    @testset "geom_col" begin
        df = @chain penguins begin
            @group_by(species, sex)
            @summarize(mean_bill_length_mm = mean(bill_length_mm))
            @ungroup()
        end
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm)) + geom_col())
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, group = sex)) + geom_col(position="dodge"))
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, dodge = sex)) + geom_col())
        @test plot_will_render(ggplot(df, @aes(x = species, y = mean_bill_length_mm, color = sex)) + geom_col())
    end
    @testset "geom_density" begin
        @test plot_will_render(ggplot(penguins, @aes(x=bill_length_mm)) +
            geom_density())
        @test plot_will_render(ggplot(penguins, @aes(x=bill_length_mm)) +
            geom_density(color = :black, stroke = 2))
    end
    @testset "geom_errorbar" begin
        df = DataFrame(
            trt   = [1, 1, 2, 2],
            resp  = [1, 5, 3, 4],
            group = [1, 2, 1, 2],
            lower = [0.8, 4.6, 2.4, 3.6],
            upper = [1.1, 5.3, 3.3, 4.2],
        )

        @test plot_will_render(ggplot(df, @aes(x = trt, ymin = lower, ymax = upper)) + geom_errorbar(linewidth=2))
        @test plot_will_render(ggplot(df, @aes(y = trt, xmin = lower, xmax = upper)) + geom_errorbarh(linewidth=2))
    end
    @testset "geom_histogram" begin
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram())
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(normalization = :probability, bins = 20))
    end
    @testset "geom_hvline" begin
        @test plot_will_render(ggplot() + geom_hline(yintercept = 3))
        @test plot_will_render(ggplot() + geom_hline(yintercept = [-1, 4]))
        df = DataFrame(y = rand(4))
        @test plot_will_render(ggplot(df, @aes(yintercept = y)) + geom_hline())
        @test plot_will_render(ggplot() + geom_vline(xintercept = 3))
        @test plot_will_render(ggplot() + geom_vline(xintercept = [-1, 4]))
        df = DataFrame(x = rand(4))
        @test plot_will_render(ggplot(df, @aes(xintercept = x)) + geom_vline())
    end
    @testset "geom_lines" begin
        xs = range(0, 2pi, length=30)
        df = DataFrame(x = xs, y = sin.(xs))

        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) + geom_line())

        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_path())

        xs = range(0, 2pi, length=30)
        df = DataFrame(x = xs, y = sin.(xs))

        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) + geom_step())
    end
    @testset "geom_point" begin
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point())
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_point(@aes(color = sex), size=20, stroke=1))
    end
    @testset "geom_smooth" begin
        xs = range(0, 2pi, length=30)
        ys = sin.(xs) .+ randn(length(xs)) * 0.5
        df = DataFrame(x = xs, y = ys)

        @test plot_will_render(ggplot(df, @aes(x = x, y = y)) + geom_smooth() + geom_point())
        @test plot_will_render(ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) + geom_smooth(color=:red, linewidth=10, alpha=0.5))
    end
    @testset "geom_text" begin
        df = DataFrame(
            x = [1,1,2,2],
            y = [1,2,1,2],
            t = ["A", "B", "C", "D"]
        )

        @test plot_will_render(ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_text())

        @test plot_will_render(ggplot(df, @aes(x=x, y=y, color=t)) +
            geom_text(@aes(text=t), fontsize=24, align=(:left, :bottom), font=:bold) +
            geom_point() +
            lims(x = (0, 3), y = (0, 3)))

        @test plot_will_render(ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_label())

        @test plot_will_render(ggplot(df, @aes(x=x, y=y, color=t)) +
            geom_label(@aes(text=t), fontsize=24, align=(:left, :bottom), font=:bold) +
            geom_point() +
            lims(x = (0, 3), y = (0, 3)))
    end
    @testset "geom_tile" begin
        function mandelbrot(x, y)
            z = c = x + y*im
            for i in 1:30.0; abs(z) > 2 && return i; z = z^2 + c; end; 0
        end

        xs = -2:0.01:1
        ys = -1.1:0.01:1.1
        xys = Iterators.product(xs, ys) |> collect |> vec
        zs = map(xy -> mandelbrot(xy[1], xy[2]), xys)

        df = DataFrame(
            x = first.(xys),
            y = last.(xys),
            z = zs
        )

        @test plot_will_render(ggplot(df, @aes(x = x, y = y, z = z)) + geom_tile())
    end
    @testset "geom_violin" begin
        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin())

        @test plot_will_render(ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin(orientation = :horizontal))

        @test plot_will_render(ggplot(penguins,
            @aes(x=species, y=bill_length_mm, dodge=sex, fill=sex)) + geom_violin())
    end
end
