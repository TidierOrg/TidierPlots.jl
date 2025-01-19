@testset "docs-render" verbose = true begin
    @testset "geom_bar" begin
        ggplot(penguins) + geom_bar(@aes(x = species))
        ggplot(penguins) + geom_bar(@aes(y = species))
        ggplot(penguins, @aes(x = species, fill=sex)) + geom_bar()
        ggplot(penguins, @aes(x = species, fill=sex, dodge = sex)) + geom_bar()
        @test true
    end
    @testset "geom_boxplot" begin
        ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
            geom_boxplot()
        ggplot(penguins, @aes(y=species, x=bill_length_mm)) +
            geom_boxplot()
        ggplot(penguins,
            @aes(x=species, y=bill_length_mm, dodge=sex, fill=sex)) + geom_boxplot()
        @test true
    end
    @testset "geom_col" begin
        df = @chain penguins begin
            @group_by(species, sex)
            @summarize(mean_bill_length_mm = mean(bill_length_mm))
            @ungroup()
        end
        ggplot(df, @aes(x = species, y = mean_bill_length_mm)) +
            geom_col()
        ggplot(df, @aes(x = species, y = mean_bill_length_mm, group = sex)) +
            geom_col(position="dodge")
        ggplot(df, @aes(x = species, y = mean_bill_length_mm, dodge = sex)) +
            geom_col()
        ggplot(df, @aes(x = species, y = mean_bill_length_mm, color = sex)) +
            geom_col()

        @test true
    end
    @testset "geom_density" begin
        ggplot(penguins, @aes(x=bill_length_mm)) +
            geom_density()
        ggplot(penguins, @aes(x=bill_length_mm)) +
                geom_density(color = :black, stroke = 2)
        @test true
    end
    @testset "geom_errorbar" begin
        df = DataFrame(
            trt   = [1, 1, 2, 2],
            resp  = [1, 5, 3, 4],
            group = [1, 2, 1, 2],
            lower = [0.8, 4.6, 2.4, 3.6],
            upper = [1.1, 5.3, 3.3, 4.2],
        )

        ggplot(df, @aes(x = trt, ymin = lower, ymax = upper)) +
            geom_errorbar(width=20, linewidth=2)

        ggplot(df, @aes(y = trt, xmin = lower, xmax = upper)) +
            geom_errorbarh(width=20, linewidth=2)
        @test true
    end
    @testset "geom_histogram" begin
        ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram()
        ggplot(penguins, @aes(x = bill_length_mm)) +
            geom_histogram(normalization = :probability, bins = 20)
        @test true
    end
    @testset "geom_hvline" begin
        ggplot() + geom_hline(yintercept = 3)
        ggplot() + geom_hline(yintercept = [-1, 4])
        df = DataFrame(y = rand(4))
        ggplot(df, @aes(yintercept = y)) + geom_hline()
        ggplot() + geom_vline(xintercept = 3)
        ggplot() + geom_vline(xintercept = [-1, 4])
        df = DataFrame(x = rand(4))
        ggplot(df, @aes(xintercept = x)) + geom_vline()
        @test true
    end
    @testset "geom_lines" begin
        xs = range(0, 2pi, length=30)
        df = DataFrame(x = xs, y = sin.(xs))

        ggplot(df, @aes(x = x, y = y)) + geom_line()

        ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_path()

        xs = range(0, 2pi, length=30)
        df = DataFrame(x = xs, y = sin.(xs))

        ggplot(df, @aes(x = x, y = y)) + geom_step()
        @test true
    end
    @testset "geom_point" begin
        ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point()

        ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_point(@aes(color = sex), size=20, stroke=1, alpha=0.6)

        @test true
    end
    @testset "geom_smooth" begin
        xs = range(0, 2pi, length=30)
        ys = sin.(xs) .+ randn(length(xs)) * 0.5
        df = DataFrame(x = xs, y = ys)

        ggplot(df, @aes(x = x, y = y)) + geom_smooth() + geom_point()

        ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
            geom_smooth(color=:red, linewidth=10, alpha=0.5)
        @test true
    end
    @testset "geom_text" begin
        df = DataFrame(
            x = [1,1,2,2],
            y = [1,2,1,2],
            t = ["A", "B", "C", "D"]
        )

        ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_text()

        ggplot(df, @aes(x=x, y=y, text=t, color=t)) +
            geom_text(fontsize=24, align=(:left, :bottom), font=:bold) +
            geom_point() +
            lims(x = (0, 3), y = (0, 3))

        ggplot(df, @aes(x=x, y=y, text=t, color=t)) + geom_label()

        ggplot(df, @aes(x=x, y=y, text=t, color=t)) +
            geom_label(fontsize=24, align=(:left, :bottom), font=:bold) +
            geom_point() +
            lims(x = (0, 3), y = (0, 3))
        @test true
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

        ggplot(df, @aes(x = x, y = y, z = z)) + geom_tile()
        @test true
    end
    @testset "geom_violin" begin
        ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin()

        ggplot(penguins, @aes(x = species, y = bill_length_mm)) +
            geom_violin(orientation = :horizontal)

        ggplot(penguins,
            @aes(x=species, y=bill_length_mm, dodge=sex, fill=sex)) + geom_violin()
        @test true
    end
end
