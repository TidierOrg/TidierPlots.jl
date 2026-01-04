function continuous_scale_to_ggoptions(args_dict::Dict)

    options_dict = Dict()

    if haskey(args_dict, "name")
        options_dict[args_dict["scale"]*"label"] = args_dict["name"]
    end

    if haskey(args_dict, "trans")
        options_dict[args_dict["scale"]*"scale"] = args_dict["trans"]
    end

    if haskey(args_dict, "reversed")
        options_dict[args_dict["scale"]*"reversed"] = args_dict["reversed"]
    end

    if haskey(args_dict, "labels")
        options_dict[Symbol(args_dict["scale"] * "tickformat")] = args_dict["labels"]
    end

    return AxisOptions(
        Dict(Symbol(k) => v for (k, v) in options_dict),
        Dict(),
        Dict()
    )

end

# Generator - generates two function signatures

function scale_template(scale, f; trans=nothing, reverse=nothing)
    function scale_function(args...; trans=trans, reverse=reverse, scale=scale, f=f, kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        if !isnothing(scale)
            args_dict["scale"] = scale
        end
        if !isnothing(trans)
            args_dict["trans"] = trans
        end
        if !isnothing(reverse)
            args_dict["reversed"] = reverse
        end
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; trans=trans, reverse=reverse, scale=scale, f=f, kwargs...)
        aes_dict, args_dict = extract_aes(args, kwargs)
        if !isnothing(scale)
            args_dict["scale"] = scale
        end
        if !isnothing(trans)
            args_dict["trans"] = trans
        end
        if !isnothing(reverse)
            args_dict["reversed"] = reverse
        end
        return plot + f(args_dict)
    end
    return scale_function
end

# Definitions

scale_x_continuous = scale_template("x", continuous_scale_to_ggoptions)
scale_y_continuous = scale_template("y", continuous_scale_to_ggoptions)
scale_x_log10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log10)
scale_y_log10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log10)
scale_x_reverse = scale_template("x", continuous_scale_to_ggoptions; reverse=true)
scale_y_reverse = scale_template("y", continuous_scale_to_ggoptions; reverse=true)
scale_x_sqrt = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.sqrt)
scale_y_sqrt = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.sqrt)
scale_x_log2 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log2)
scale_y_log2 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log2)
scale_x_log = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.log)
scale_y_log = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.log)
scale_x_logit = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.logit)
scale_y_logit = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.logit)
scale_x_pseudolog10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.pseudolog10)
scale_y_pseudolog10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.pseudolog10)
scale_x_symlog10 = scale_template("x", continuous_scale_to_ggoptions; trans=Makie.Symlog10)
scale_y_symlog10 = scale_template("y", continuous_scale_to_ggoptions; trans=Makie.Symlog10)

@testitem "scale_x/y_continuous" begin
    t = ggplot(penguins, @aes(x = body_mass_g, y = bill_length_mm)) +
        geom_point() +
        scale_x_continuous(
            name="Mass (g)",
            trans=log10
        ) +
        scale_y_continuous(
            name="Length",
            reversed=true,
            labels=label_number(; suffix="mm")
        )

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.body_mass_g,
                        penguins.bill_length_mm;
                    )],
                xlabel="Mass (g)",
                xscale=log10,
                ylabel="Length",
                yreversed=true,
                ytickformat=label_number(; suffix="mm")),
        ])
    )

    @test plot_images_equal(t, m)

    scale = TidierPlots.continuous_scale_to_ggoptions(
        Dict("scale" => "x", "trans" => log, "reversed" => true)
    )
    @test scale.opt[:xreversed] == true
    @test scale.opt[:xscale] == log

    scale = scale_x_reverse()

    @test scale.opt[:xreversed] == true

    t = ggplot(DataFrame(x=[1, 2], y=[2, 3], shape=["a", "b"])) +
        geom_point(aes(x=:x, y=:y, shape=:shape)) + scale_shape()

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        [1, 2],
                        [2, 3]; marker=[:circle, :cross]
                    )]
            ), (1, 2) => Makie.SpecApi.Legend(
                [MarkerElement(marker=:circle, markersize=12),
                    MarkerElement(marker=:cross, markersize=12)],
                ["a", "b"], "marker"
            )
        ])
    )

    @test plot_images_equal(t, m)

    t = ggplot(DataFrame(x=[1, 2], y=[2, 3])) +
        geom_point(aes(x=:x, y=:y, size=:y)) + scale_size(range=[5, 10])

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        [1, 2],
                        [2, 3]; markersize=[5, 10]
                    )]
            ), (1, 2) => Makie.SpecApi.Legend(
                [MarkerElement(marker=:circle, markersize=5),
                    MarkerElement(marker=:circle, markersize=6.25),
                    MarkerElement(marker=:circle, markersize=7.5),
                    MarkerElement(marker=:circle, markersize=8.75),
                    MarkerElement(marker=:circle, markersize=10)],
                ["2.0", "2.25", "2.5", "2.75", "3.0"], "markersize"
            )
        ])
    )

    @test plot_images_equal(t, m)

    t = ggplot(DataFrame(x=[1, 2, 1, 2],
        y=[2, 3, 1, 4],
        l=[1, 1, 2, 2])) +
        geom_line(aes(x=:x, y=:y, group=:l, linewidth=:l))

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [2, 3];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0)
                    ),
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [1, 4];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0), linewidth=2
                    )]
            )
        ])
    )

    t = ggplot(DataFrame(x=[1, 2, 1, 2],
        y=[2, 3, 1, 4],
        l=[1, 1, 2, 2])) +
        geom_line(aes(x=:x, y=:y, group=:l, alpha=:l)) + scale_alpha()

    m = Makie.plot(
        Makie.SpecApi.GridLayout([
            (1, 1) => Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [2, 3];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0)
                    ),
                    Makie.PlotSpec(
                        :Lines,
                        [1, 2],
                        [1, 4];
                        color=RGBA(0.0, 0.4470588235294118, 0.6980392156862745, 1.0)
                    )]
            )
        ])
    )

    @test plot_images_equal(t, m)
end
