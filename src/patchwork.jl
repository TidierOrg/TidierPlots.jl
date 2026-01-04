# functions to implement the functionality of R's {patchwork} package
function combine_plots(catfunc::Function, args::Union{GGPlot,GGPlotGrid}...)
    all_plots = GGPlot[]
    for a in args
        if isa(a, GGPlot)
            push!(all_plots, a)
        else
            push!(all_plots, a.plots...)
        end
    end
    all_axes = [isa(a, GGPlot) ? as_GridLayout(a) : a.grid for a in args]
    return GGPlotGrid(
        all_plots,
        Makie.SpecApi.GridLayout(
            catfunc(
                all_axes...
            )
        )
    )
end

# + -> side by side
function Base.:+(args::Union{GGPlot,GGPlotGrid,GGPlotGridSpec}...)
    if any(isa.(args, GGPlotGridSpec))
        return add_gridspec(args...)
    else
        return combine_plots(hcat, args...)
    end
end

# | -> side by side
Base.:|(args::Union{GGPlot,GGPlotGrid}...) = combine_plots(hcat, args...)

# / -> p1 above p2
Base.:/(args::Union{GGPlot,GGPlotGrid}...) = combine_plots(vcat, args...)

# Define plot layout
function plot_layout(; ncol=0, nrow=0, byrow=false, widths=Int[], heights=Int[])
    return GGPlotGridSpec(ncol, nrow, byrow, widths, heights)
end

function add_gridspec(args::Union{GGPlot,GGPlotGrid,GGPlotGridSpec}...)
    # Separate plots from gridspec
    plots = Union{GGPlot,GGPlotGrid}[]
    gridspecl = GGPlotGridSpec[]
    gridspec = nothing
    for arg in args
        if arg isa GGPlotGridSpec
            push!(gridspecl, arg)
        else
            push!(plots, arg)
        end
    end

    if length(gridspecl) > 1
        ncol = all([f.ncol == 0 for f in gridspecl]) ? 0 :
            last([f.ncol for f in gridspecl if f.ncol > 0])
        nrow = all([f.nrow == 0 for f in gridspecl]) ? 0 :
            last([f.nrow for f in gridspecl if f.nrow > 0])
        widths = all([length(f.widths) == 0 for f in gridspecl]) ? Int64[] :
            last([f.widths for f in gridspecl if length(f.widths) > 0])
        heights = all([length(f.heights) == 0 for f in gridspecl]) ? Int64[] :
            last([f.heights for f in gridspecl if length(f.heights) > 0])
        gridspec = GGPlotGridSpec(ncol,nrow,
            any([f.byrow for f in gridspecl]),widths,heights)
    else length(gridspecl) == 1
        gridspec = gridspecl[1]
    end

    # Arrange plots
    nplots = length(plots)
    ncol = gridspec.ncol
    nrow = gridspec.nrow
    if (nrow == 0) & (ncol == 0)
        # Default: more cols than rows
        nrow = Int(round(sqrt(nplots)))
        ncol = Int(ceil(sqrt(nplots)))
    elseif (nrow == 0)
        # As many rows as needed
        nrow = Int(ceil(nplots / ncol))
    elseif (ncol == 0)
        # As many cols as needed
        ncol = Int(ceil(nplots / nrow))
    end
    layout = Pair{Tuple{Int64,Int64},Union{Makie.BlockSpec,Makie.GridLayoutSpec}}[]
    plot_i = 1
    if gridspec.byrow
        for j in 1:ncol, i in 1:nrow
            if plot_i <= nplots
                tmp_plot = plots[plot_i]
                axis = tmp_plot isa GGPlot ? as_GridLayout(tmp_plot) : tmp_plot.grid
                push!(layout, (i, j) => axis)
                plot_i += 1
            end
        end
    else
        for i in 1:nrow, j in 1:ncol
            if plot_i <= nplots
                tmp_plot = plots[plot_i]
                axis = tmp_plot isa GGPlot ? as_GridLayout(tmp_plot) : tmp_plot.grid
                push!(layout, (i, j) => axis)
                plot_i += 1
            end
        end
    end

    # Adjust sizes
    widths = isempty(gridspec.widths) ? ones(ncol) : gridspec.widths
    heights = isempty(gridspec.heights) ? ones(nrow) : gridspec.heights
    total_width = sum(widths)
    total_height = sum(heights)
    all_plots = GGPlot[]
    for p in plots
        if isa(p, GGPlot)
            push!(all_plots, p)
        else
            push!(all_plots, p.plots...)
        end
    end
    return GGPlotGrid(
        all_plots,
        Makie.SpecApi.GridLayout(
            layout,
            colsizes=[Relative(w / total_width) for w in widths],
            rowsizes=[Relative(h / total_height) for h in heights]
        )
    )
end


    @testitem "horizontal concatenation" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[
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

    @testitem "vertical concatenation" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[
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

    @testitem "grid concatenation" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[
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

    @testitem "plot layout organization" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        t2 = ggplot(penguins) +
             geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
            )]
        )
        test_ax2 = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
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
        @test plot_images_equal(t + t2 + t + t2 + plot_layout(ncol=2, nrow=2), m22)
        @test plot_images_equal(t + t + t2 + t2 + plot_layout(ncol=2, nrow=2, byrow=true), m22)
        @test plot_images_equal(t + t2 + t + t2 + plot_layout(ncol=2, nrow=0), m22)

        # 2x2 grid (missing bottom right)
        m21 = Makie.plot(
            Makie.SpecApi.GridLayout([
                (1, 1) => test_ax,
                (1, 2) => test_ax2,
                (2, 1) => test_ax
            ]
            )
        )
        @test plot_images_equal(t + t2 + t + plot_layout(nrow=2, ncol=2), m21)
        @test plot_images_equal(t + t2 + t + plot_layout(nrow=2), m21)
        @test plot_images_equal(t + t2 + t + plot_layout(), m21)

        # 1x3 grid
        m13 = Makie.plot(
            Makie.SpecApi.GridLayout([
                (1, 1) => test_ax,
                (1, 2) => test_ax,
                (1, 3) => test_ax
            ]
            )
        )
        @test plot_images_equal(t + t + t + plot_layout(nrow=1), m13)
    end

    @testitem "plot layout sizes" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        t2 = ggplot(penguins) +
             geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
            )]
        )
        test_ax2 = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter, penguins.bill_depth_mm, penguins.bill_length_mm
            )]
        )
        # 2x2 grid (variable columns widths)
        m22c = Makie.plot(
            Makie.SpecApi.GridLayout([
                    test_ax test_ax2;
                    test_ax test_ax2
                ],
                colsizes=[Relative(1 / 3), Relative(2 / 3)]
            )
        )
        @test plot_images_equal(t + t2 + t + t2 + plot_layout(widths=[1, 2]), m22c)

        # 2x2 grid (missing bottom right)
        m21 = Makie.plot(
            Makie.SpecApi.GridLayout([
                    (1, 1) => test_ax,
                    (1, 2) => test_ax2,
                    (2, 1) => test_ax
                ],
                colsizes=[Relative(1 / 3), Relative(2 / 3)]
            )
        )
        @test plot_images_equal(t + t2 + t + plot_layout(widths=[1, 2]), m21)

        # 2x2 grid (variable row heights)
        m22r = Makie.plot(
            Makie.SpecApi.GridLayout([
                    test_ax test_ax2;
                    test_ax test_ax2
                ],
                rowsizes=[Relative(1 / 3), Relative(2 / 3)]
            )
        )
        @test plot_images_equal(t + t2 + t + t2 + plot_layout(heights=[1, 2]), m22r)

        # 1x3 grid
        m13 = Makie.plot(
            Makie.SpecApi.GridLayout([
                    (1, 1) => test_ax,
                    (1, 2) => test_ax,
                    (1, 3) => test_ax
                ],
                colsizes=[Relative(1 / 6), Relative(2 / 6), Relative(3 / 6)]
            )
        )
        @test plot_images_equal(t + t + t + plot_layout(nrow=1, widths=[1, 2, 3]), m13)

        # 2x3 grid variable height and width
        m23 = Makie.plot(
            Makie.SpecApi.GridLayout([
                    (1, 1) => test_ax,
                    (1, 2) => test_ax,
                    (1, 3) => test_ax,
                    (2, 1) => test_ax2,
                    (2, 2) => test_ax2,
                    (2, 3) => test_ax2
                ],
                colsizes=[Relative(1 / 6), Relative(2 / 6), Relative(3 / 6)],
                rowsizes=[Relative(1 / 5), Relative(4 / 5)]
            )
        )
        @test plot_images_equal(t + t + t + t2 + t2 + t2 + plot_layout(nrow=2, widths=[1, 2, 3], heights=[1, 4]), m23)
        @test plot_images_equal(t + t + t + t2 + t2 + t2 + plot_layout(nrow=2, widths=[1, 2, 3]) + plot_layout(heights=[1, 4]), m23)
    end

    @testitem "plot layout grids" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))
        t2 = ggplot(penguins) +
             geom_point(@aes(x = bill_depth_mm, y = bill_length_mm))
        test_ax = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter, penguins.bill_length_mm, penguins.bill_depth_mm
            )]
        )
        test_ax2 = Makie.SpecApi.Axis(
            plots=[Makie.PlotSpec(
                :Scatter, penguins.bill_depth_mm, penguins.bill_length_mm
            )]
        )
        m22c = Makie.plot(
            Makie.SpecApi.GridLayout([
                    Makie.SpecApi.GridLayout([test_ax test_ax]) test_ax2;
                    test_ax test_ax2
                ],
                colsizes=[Relative(1 / 3), Relative(2 / 3)]
            )
        )
        @test plot_images_equal((t | t) + t2 + t + t2 + plot_layout(widths=[1, 2]), m22c)
    end
