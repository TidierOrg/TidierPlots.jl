function make_color_lookup_manual(args_dict::Dict)
    colors = eltype(args_dict[:values]) <: Colorant ?
             args_dict[:values] :
             parse.(Colors.RGBA, args_dict[:values])

    function color_lookup_manual(input::T) where {T <: Union{Colorant,Vector{Colorant}}}
        return input
    end
    function color_lookup_manual(input::Any)
        return [colors[mod1(x, length(colors))] for x in levelcode.(CategoricalArray(input))]
    end
    function color_lookup_manual(input::CategoricalArray)
        return [colors[mod1(levelcode(x), length(colors))] for x in input]
    end
    function color_lookup_manual(input::Integer)
        return [colors[mod1(x, length(colors))] for x in input]
    end
    return color_lookup_manual
end

function make_color_lookup_discrete(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in discrete color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $(typeof(palette))"))
    end

    function color_lookup_discrete(input::Any)
        return scheme[levelcode.(CategoricalArray(input))]
    end
    function color_lookup_discrete(input::CategoricalArray)
        return scheme[levelcode.(input)]
    end
    function color_lookup_discrete(input::Integer)
        return scheme[input]
    end
    function color_lookup_discrete(input::AbstractFloat)
        return scheme[round.(Integer, input)]
    end

    return color_lookup_discrete
end

function make_color_lookup_continuous(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in continuous color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $(typeof(palette))"))
    end

    function color_lookup_continuous(input)
        return get(scheme, input ./ maximum(input))
    end
    return color_lookup_continuous
end

function make_color_lookup_binned(args_dict::Dict)
    palette = haskey(args_dict, :palette) ? args_dict[:palette] :
              haskey(args_dict, :values) ? args_dict[:values][1] : nothing

    if isnothing(palette)
        throw(ArgumentError("Invalid palette specification in binned color scale."))
    end

    scheme = palette isa Symbol ? ColorSchemes.colorschemes[palette] :
             palette isa String ? ColorSchemes.colorschemes[Symbol(palette)] :
             palette isa ColorScheme ? palette : nothing

    if isnothing(scheme)
        palette_type = typeof(palette)
        throw(ArgumentError("Palette should be a String, a Symbol, or a ColorScheme, not a $palette_type"))
    end

    function color_lookup_binned(input)
        input = convert.(Float64, input)

        binned_input = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))

        return scheme[binned_input]
    end
    return color_lookup_binned
end

function color_scale_to_ggoptions(args_dict::Dict)

    lookup = args_dict[:type] == "manual" ?
             make_color_lookup_manual(args_dict) :
             args_dict[:type] == "discrete" ?
             make_color_lookup_discrete(args_dict) :
             args_dict[:type] == "continuous" ?
             make_color_lookup_continuous(args_dict) :
             make_color_lookup_binned(args_dict)

    palette = Dict()

    args_dict[:guide] = args_dict[:type] in ["manual", "discrete"] ?
                        :legend : :colorbar

    if args_dict[:scale] == "color"
        palette[:color] = lookup
    elseif args_dict[:scale] == "fill"
        palette[:fill] = lookup
    else
        throw(ArgumentError("Unrecognized scale: $(args_dict[:scale])"))
    end

    return AxisOptions(
        Dict(),
        palette,
        Dict(:color => args_dict) # pass the full args dict for use by legend
    )
end

function color_scale_template(scale, f, type)
    function scale_function(args...; scale=scale, f=f, type=type, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        args_dict[:type] = type
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return f(args_dict)
    end
    function scale_function(plot::GGPlot, args...; scale=scale, f=f, kwargs...)
        args_dict = merge(Dict(kwargs), Dict())
        args_dict[:scale] = scale
        args_dict[:type] = type
        if !haskey(args_dict, :values)
            args_dict[:values] = [args...]
        end
        return plot + f(args_dict)
    end
    return scale_function
end

# default palettes

const _default_discrete_palette = make_color_lookup_manual(
    Dict(:values => [
        RGB(0 / 255, 114 / 255, 178 / 255), # blue
        RGB(230 / 255, 159 / 255, 0 / 255), # orange
        RGB(0 / 255, 158 / 255, 115 / 255), # green
        RGB(204 / 255, 121 / 255, 167 / 255), # reddish purple
        RGB(86 / 255, 180 / 255, 233 / 255), # sky blue
        RGB(213 / 255, 94 / 255, 0 / 255), # vermillion
        RGB(240 / 255, 228 / 255, 66 / 255), # yellow
    ])
)
const _default_continuous_palette = make_color_lookup_continuous(
    Dict(:palette => :viridis)
)

# scale definitions

scale_colour_manual = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "manual")

scale_color_manual = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "manual")

scale_colour_discrete = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "discrete")

scale_color_discrete = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "discrete")

scale_colour_continuous = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "continuous")

scale_color_continuous = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "continuous")

scale_colour_binned = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "binned")

scale_color_binned = color_scale_template(
    "color",
    color_scale_to_ggoptions,
    "binned")

scale_fill_manual = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "manual")

scale_fill_discrete = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "discrete")

scale_fill_continuous = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "continuous")

scale_colour_binned = color_scale_template(
    "fill",
    color_scale_to_ggoptions,
    "binned")

scale_alpha_continuous = color_scale_template(
    "alpha",
    alpha_scale_to_ggoptions,
    "continuous"
)

scale_alpha = color_scale_template(
    "alpha",
    alpha_scale_to_ggoptions,
    "continuous"
)

    @testitem "discrete color scale" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:species)) +
            scale_color_discrete(palette="julia")

        colours = ColorSchemes.colorschemes[:julia]

        cat_array = CategoricalArray(penguins.species)

        l = Makie.SpecApi.Legend(
            [MarkerElement(color=colours[1], markersize=12, marker=:circle),
                MarkerElement(color=colours[2], markersize=12, marker=:circle),
                MarkerElement(color=colours[3], markersize=12, marker=:circle)],
            ["Adelie", "Chinstrap", "Gentoo"],
            "species")  # Legend title is now the column name

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=(x -> colours[x]).(levelcode.(cat_array))
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_discrete()
        @test_throws ArgumentError md = TidierPlots.make_color_lookup_discrete(
            Dict(:wrongname => [1])
        )
        @test_throws ArgumentError md = TidierPlots.make_color_lookup_discrete(
            Dict(:palette => [1])
        )

        s = scale_color_discrete(palette="julia")
        @test s.palette[:color](1) == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](["a"])[1] == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](1.2) == Colors.RGB{N0f8}(0.122, 0.514, 1.0)
        @test s.palette[:color](CategoricalArray(["a"]))[1] ==
              Colors.RGB{N0f8}(0.122, 0.514, 1.0)
    end

    @testitem "manual color scale" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:species)) +
            scale_color_manual("red", "white", "blue")

        colours = parse.(Colors.RGBA, ["red", "white", "blue"])

        cat_array = CategoricalArray(penguins.species)

        l = Makie.SpecApi.Legend(
            [MarkerElement(color=colours[1], markersize=12, marker=:circle),
                MarkerElement(color=colours[2], markersize=12, marker=:circle),
                MarkerElement(color=colours[3], markersize=12, marker=:circle)],
            ["Adelie", "Chinstrap", "Gentoo"],
            "species")  # Legend title is now the column name

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=(x -> colours[x]).(levelcode.(cat_array))
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        ml = TidierPlots.make_color_lookup_manual(
            Dict(:values => [:red, :blue, :white])
        )

        @test all(ml([1.2, 1.8]) .== [Colors.RGBA(1.0, 0.0, 0.0, 1.0), Colors.RGBA(0.0, 0.0, 1.0, 1.0)])
    end

    @testitem "continuous color scale" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:bill_depth_mm)) +
            scale_color_continuous(palette=:Purples_5)

        colours = get(ColorSchemes.colorschemes[:Purples_5],
            penguins.bill_depth_mm ./ maximum(penguins.bill_depth_mm))

        l = Makie.SpecApi.Colorbar(; colormap=:Purples_5,
            limits=(minimum(penguins.bill_depth_mm),
                maximum(penguins.bill_depth_mm)), label="bill_depth_mm")  # Colorbar label is now the column name

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=colours
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_continuous()
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_continuous(Dict(:palette => [1]))
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_continuous(Dict(:wrongname => [1]))


        s = scale_color_continuous(palette="julia")
        @test s.palette[:color](1) == RGB{Float64}(
            0.5725490196078431,
            0.34901960784313724,
            0.6392156862745098)

        # Test that default continuous color shows a colorbar
        gg1 = ggplot(DataFrame(x=[1.0, 2.2], y=[1.1, 2.3])) +
              geom_point(aes(x=:x, y=:y, color=:x))

        # gg1 now shows a colorbar by default, so it should NOT equal gg2 with guides(none)
        gg2 = ggplot(DataFrame(x=[1.0, 2.2], y=[1.1, 2.3])) +
              geom_point(aes(x=:x, y=:y, color=:x)) + scale_colour_continuous(palette=:viridis) +
              guides(color="none")

        @test !plot_images_equal(gg1, gg2)  # They should NOT be equal now

        # Test that explicit guides(none) hides the colorbar
        gg3 = ggplot(DataFrame(x=[1.0, 2.2], y=[1.1, 2.3])) +
              geom_point(aes(x=:x, y=:y, color=:x)) + guides(color="none")

        @test plot_images_equal(gg2, gg3)  # Both should have no colorbar
    end

    @testitem "binned color scale" setup=[TidierPlotsSetup] begin
        t = ggplot(penguins) +
            geom_point(aes(x=:bill_depth_mm, y=:bill_length_mm, color=:bill_depth_mm)) +
            scale_color_binned(palette=:Purples_5)

        input = penguins.bill_depth_mm

        colours = ceil.(Int, 1 .+ 4 .* ((input .- minimum(input)) ./ (maximum(input) - minimum(input))))

        l = Makie.SpecApi.Colorbar(;
            colormap=cgrad(:Purples_5, 5, categorical=true),
            limits=(minimum(penguins.bill_depth_mm),
                maximum(penguins.bill_depth_mm)), label="bill_depth_mm")  # Colorbar label is now the column name

        m = Makie.plot(
            Makie.SpecApi.GridLayout(
                [Makie.SpecApi.Axis(
                    plots=[
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.bill_length_mm;
                            color=ColorSchemes.colorschemes[:Purples_5][colours]
                        )
                    ]
                ) l]
            )
        )

        @test plot_images_equal(t, m)

        @test_throws MethodError md = TidierPlots.make_color_lookup_binned()
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_binned(Dict(:palette => [1]))
        @test_throws ArgumentError md =
            TidierPlots.make_color_lookup_binned(Dict(:wrongname => [1]))
    end

    @testitem "color_scale_to_ggoptions error handling" setup=[TidierPlotsSetup] begin
    @test_throws ArgumentError TidierPlots.color_scale_to_ggoptions(
        Dict(
            :type => "manual",
            :scale => "bad",
            :values => [:red, :blue]
        )
    )
end

@testitem "color_scale_to_ggoptions color interpretation" setup=[TidierPlotsSetup] begin
    tfill = TidierPlots.color_scale_to_ggoptions(
        Dict(
            :type => "manual",
            :scale => "fill",
            :values => [:red, :blue]
        )
    )
    @test tfill.palette[:fill](1)[1] == Colors.RGBA(1.0, 0.0, 0.0, 1.0)
end
