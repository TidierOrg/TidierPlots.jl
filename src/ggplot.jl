function ggplot(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    if haskey(args_dict, "data")
        if args_dict["data"] isa DataFrame
            plot_data = args_dict["data"]
            delete!(args_dict, "data")
        else
            throw(ArgumentError("Data should be provided as a DataFrame, not as a $(typeof(args_dict["data"]))"))
        end
    else
        plot_data = nothing
    end

    GGPlot([],
        aes_dict,
        plot_data,
        AxisOptions(args_dict, Dict(), Dict()),
        theme_ggplot2(),
        nothing)
end

function ggplot(data::DataFrame, args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    GGPlot([],
        aes_dict,
        data,
        AxisOptions(args_dict, Dict(), Dict()),
        theme_ggplot2(),
        nothing)
end

@testitem "data" begin
    using DataFrames
    @test_throws ArgumentError ggplot(data=["not", "a", "DataFrame"])
    @test_throws ArgumentError geom_point((data = ["not", "a", "DataFrame"]),
        aes(x=:x, y=:y))

    @test c(1, 2, 3) == [1, 2, 3]
    @test_nowarn c(1, 2, 3)

    gg1 = ggplot(data=DataFrame(a=[1, 2]))
    gg2 = ggplot(DataFrame(a=[1, 2]))

    @test all(gg1.data.a .== gg2.data.a)
end

@testitem "inherit aes" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins, aes(color = :species)) +
        geom_point(aes(x = :bill_length_mm, y = :bill_depth_mm), inherit_aes = false)

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

@testitem "unsupported options" begin
    using DataFrames
    @test_throws ArgumentError draw_ggplot(ggplot(DataFrame(x = [1,2], y = [1,2])) + geom_point(aes(x = :x, y = :y), unsuparg = 1))
end
