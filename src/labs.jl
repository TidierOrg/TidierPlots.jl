function labs(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    ggplot_to_makie = Dict(
        "title" => :title,
        "x" => :xlabel,
        "y" => :ylabel,
        "subtitle" => :subtitle
    )

    return AxisOptions(
        Dict(ggplot_to_makie[k] => v for (k, v) in args_dict if k in keys(ggplot_to_makie)),
        Dict(),
        Dict(Symbol(k) => Dict(:name => v) for (k, v) in args_dict if !(k in keys(ggplot_to_makie)))
    )
end

function labs(plot::GGPlot, args...; kwargs...)
    return plot + labs(args...; kwargs...)
end

function lims(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    lims_dict = Dict{Symbol,Any}()

    if haskey(args_dict, "x")
        if haskey(args_dict, "y")
            lims_dict[:limits] = (
                (args_dict["x"][1], args_dict["x"][2]),
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict[:limits] = (
                (args_dict["x"][1], args_dict["x"][2]),
                nothing
            )
        end
    else
        if haskey(args_dict, "y")
            lims_dict[:limits] = (
                nothing,
                (args_dict["y"][1], args_dict["y"][2])
            )
        else
            lims_dict[:limits] = (
                nothing,
                nothing
            )
        end
    end

    return AxisOptions(lims_dict, Dict(), Dict())
end

function lims(plot::GGPlot, args...; kwargs...)
    return plot + lims(args...; kwargs...)
end


@testitem "lims" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

    m_xlim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits=((30, 60), (nothing, nothing))
            )
        )
    )

    @test plot_images_equal(t + lims(x=(30, 60)), m_xlim)

    m_ylim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits=((nothing, nothing), (10, 25))
            )
        )
    )

    @test plot_images_equal(t + lims(y=(10, 25)), m_ylim)

    m_xylim = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; limits=((30, 60), (10, 25))
            )
        )
    )

    @test plot_images_equal(t + lims(x=(30, 60), y=(10, 25)), m_xylim)

    lm = lims(ggplot(), x=(30, 60))

    @test lm.axis_options.opt[:limits] == ((30, 60), nothing)

    no_limits = lims()

    @test no_limits.opt[:limits] == (nothing, nothing)
end


@testitem "Labs" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

    m_title = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; title="Title"
            )
        )
    )

    @test plot_images_equal(t + labs(title="Title"), m_title)

    m_xlab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X"), m_xlab)

    m_ylab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; ylabel="Y"
            )
        )
    )

    @test plot_images_equal(t + labs(y="Y"), m_ylab)

    m_xylab = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X", ylabel="Y"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X", y="Y"), m_xylab)

    m_xylab_title = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots=[
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm,
                        penguins.bill_depth_mm)
                ]; xlabel="X", ylabel="Y", title="Title"
            )
        )
    )

    @test plot_images_equal(t + labs(x="X", y="Y", title="Title"), m_xylab_title)

    l = labs(ggplot(), x="Test")

    @test l.axis_options.opt[:xlabel] == "Test"

end
