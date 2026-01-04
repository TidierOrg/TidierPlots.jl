"""
    aes(args...; kwargs...)

# Details

TBD
"""
function aes(args...; kwargs...)
    aes_args = Pair[]
    aes_kwargs = Dict{Symbol,Pair}()

    for arg in args
        if arg isa Pair
            throw(ErrorException("Calculations are not supported in positional aes specs."))
        else
            push!(aes_args, Symbol(arg) => identity)
        end
    end

    d = Dict(kwargs)

    for (k, v) in d
        if v isa Pair
            push!(aes_kwargs, Symbol(k) => v)
        else
            push!(aes_kwargs, Symbol(k) => Symbol(v) => identity)
        end
    end

    return Aesthetics(aes_args, aes_kwargs)
end

macro aes(exprs...)
    exprs = TidierData.parse_blocks(exprs...)
    interpolated_exprs = TidierData.parse_interpolation.(exprs)
    tidy_exprs = [i[1] for i in interpolated_exprs]
    mapping = TidierData.parse_tidy.(tidy_exprs)

    aes_args = Pair[]
    aes_kw = Dict{Symbol,Pair}()

    for aes in mapping
        if aes isa QuoteNode # positional aes with no transformations
            push!(aes_args, aes.value => identity)
        elseif aes.args[1] == :Cols
            throw(ErrorException("Calculations are not supported in positional aes specs."))
        elseif aes.args[2] isa QuoteNode
            push!(aes_kw, aes.args[3].value => aes.args[2].value => identity)
        else
            tf = eval(aes)
            push!(aes_kw, tf[2][2] => tf[1] => tf[2][1])
        end
    end

    return Aesthetics(aes_args, aes_kw)
end

# COV_EXCL_START

function Base.show(io::IO, aes::Aesthetics)
    println("A TidierPlots aes mapping object.")
    println("Positional:")

    for pos in aes.positional
        println(pos)
    end

    println("Named:")

    for (k, v) in aes.named
        println("$k : $v")
    end
end

# COV_EXCL_STOP

@eval const $(Symbol("@es")) = $(Symbol("@aes"))

@testitem "Aes operations" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm => (x -> x .+ 10),
                       y = :bill_depth_mm => (y -> y .+ 20)))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .+ 10,
                        penguins.bill_depth_mm .+ 20)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) ->x .+ y), y = :bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .+ penguins.bill_depth_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm => (x -> x .- 10),
                       y = :bill_depth_mm => (y -> y .- 20)))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .- 10,
                        penguins.bill_depth_mm .- 20)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) ->x .- y), y = :bill_depth_mm))
    tm = ggplot(penguins) +
                geom_point(@aes(x = bill_length_mm - bill_depth_mm,
                                y = bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .- penguins.bill_depth_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    @test plot_images_equal(tm, m)
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm => (x -> x .* 10),
                       y = :bill_depth_mm => (y -> y .* 20)))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .* 10,
                        penguins.bill_depth_mm .* 20)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) ->x .* y), y = :bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm .* penguins.bill_depth_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm => (x -> x ./ 10),
                       y = :bill_depth_mm => (y -> y ./ 20)))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm ./ 10,
                        penguins.bill_depth_mm ./ 20)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    t = ggplot(penguins) +
        geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => ((x, y) ->x ./ y), y = :bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm ./ penguins.bill_depth_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    my_func(x) = x ./ 10
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_length_mm => my_func, y = :bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm ./ 10,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
    my_func(x, y) = x ./ y
    t = ggplot(penguins) +
        geom_point(aes(x = [:bill_length_mm, :bill_depth_mm] => my_func, y= :bill_depth_mm))
    m = Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = [
                    Makie.PlotSpec(
                        :Scatter,
                        penguins.bill_length_mm ./ penguins.bill_depth_mm,
                        penguins.bill_depth_mm)
                ]
            )
        )
    )
    @test plot_images_equal(t, m)
end

@testitem "Aes specifications" setup=[TidierPlotsSetup] begin
    function Base.:(==)(aes1::TidierPlots.Aesthetics, aes2::TidierPlots.Aesthetics)
        if length(aes1.positional) != 0 || length(aes2.positional) != 0
            if length(aes2.positional) != length(aes1.positional)
                return false
            end
            if any(aes1.positional .!= aes2.positional)
                return false
            end
        end

        if length(aes1.named) != 0 || length(aes2.named) != 0
            if length(aes2.named) != length(aes1.named)
                return false
            end
            if length(intersect(keys(aes1.named), keys(aes2.named))) != length(aes1.    named)
                return false
            end
            for (k, v) in aes1.named
                if aes2.named[k] != v
                    return false
                end
            end
        end

        return true
    end

    @test aes(x = "x", y = "y") == @aes(x = x, y = y)
    @test aes(x = "x", y = "y") == @es(x = x, y = y)
    @test aes(x = "x", y = "y") == aes(x = :x, y = :y)
    @test aes("x", "y") == @aes(x, y)
    @test aes("x", "y") == @es(x, y)
    @test aes("x", "y") == aes(:x, :y)
    @test aes("x", y = "y") == aes(:x, y = :y)
    @test aes("x", y = "y") == @es(x, y = y)
    @test aes("x", y = "y") == @aes(x, y = y)
    @test_throws ErrorException @macroexpand @aes(x/10)
    to_cm(x) = x ./ 10
    @test_throws ErrorException aes(:x => to_cm)
end
