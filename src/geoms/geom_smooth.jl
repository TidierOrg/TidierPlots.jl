"""
    geom_smooth(aes(...), ...)
    geom_smooth(plot::GGPlot, aes(...), ...)

Represent data as a smoothed or linear fit.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- NA

# Optional Arguments

- `method`: either "smooth" (default, loess fit) or "lm" (linear fit)
- `color` / `colour`
- `linewidth`
- `alpha`
- `linestyle` / `linetype`

# Examples

```julia
xs = range(0, 2pi, length=30)
ys = sin.(xs) .+ randn(length(xs)) * 0.5
df = DataFrame(x = xs, y = ys)

ggplot(df, @aes(x = x, y = y)) + geom_smooth() + geom_point()

penguins = penguins_data()

ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_smooth(color=:red, linewidth=10, alpha=0.5)
```
"""
function geom_smooth(plot::GGPlot, args...; kwargs...)
    return plot + geom_smooth(args...; kwargs...)
end

function geom_smooth(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)
    args_dict["geom_name"] = "geom_smooth"

    if get(args_dict, "method", "smooth") == "lm"
        return [build_geom(aes_dict,
                args_dict,
                ["x", "y"],
                :Lines;
                post_function=stat_linear),
            build_geom(aes_dict,
                merge(Dict(:alpha => 0.6), args_dict),
                ["x", "lower", "upper"],
                :Band,
                post_function=stat_linear)]
    end

    return build_geom(aes_dict,
        args_dict,
        ["x", "y"],
        :Lines,
        post_function=stat_loess)
end

function stat_loess(
    aes_dict,
    args_dict,
    required_aes::Vector{String},
    plot_data::DataFrame
)
    x = plot_data[!, :x]
    y = plot_data[!, :y]
    group = first(plot_data[!, :group])

    model = Loess.loess(x, y; span=0.75, degree=2)
    x̂ = range(extrema(x)..., length=200)
    ŷ = Loess.predict(model, x̂)

    return_data = DataFrame(
        "x" => x̂,
        "y" => ŷ,
        "group" => repeat([group], 200)
    )

    return (aes_dict, args_dict, required_aes, return_data)
end

function stat_linear(
    aes_dict,
    args_dict,
    required_aes::Vector{String},
    plot_data::DataFrame
)
    x = plot_data[!, :x]
    y = plot_data[!, :y]
    group = first(plot_data[!, :group])

    # thanks AlgebraOfGraphics
    function add_intercept_column(x::AbstractVector{T}) where {T}
        mat = similar(x, float(T), (length(x), 2))
        fill!(view(mat, :, 1), 1)
        copyto!(view(mat, :, 2), x)
        return mat
    end

    lin_model = GLM.lm(add_intercept_column(x), y)
    x̂ = range(extrema(x)..., length=100)
    pred = DataFrame(
        GLM.predict(lin_model, add_intercept_column(x̂); interval=:confidence)
    )

    return_data = DataFrame(
        "x" => x̂,
        "y" => pred.prediction,
        "lower" => pred.lower,
        "upper" => pred.upper,
        "group" => repeat([group], 100)
    )

    return (aes_dict, args_dict, required_aes, return_data)
end

 @testitem "geom_smooth" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins, aes(x="bill_length_mm", y="bill_depth_mm")) +
        geom_smooth() + geom_point()

    model = Loess.loess(penguins.bill_length_mm, penguins.bill_depth_mm; span=0.75, degree=2)
    x̂ = range(extrema(penguins.bill_length_mm)..., length=200)
    ŷ = Loess.predict(model, x̂)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Lines,
              x̂,
              ŷ),
            Makie.PlotSpec(
              :Scatter,
              penguins.bill_length_mm,
              penguins.bill_depth_mm
            )
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = @chain ggplot(penguins, aes(x="bill_length_mm", y="bill_depth_mm")) begin
      geom_smooth
      geom_point
    end

    @test plot_images_equal(t, t2)

    t = ggplot(penguins, aes(x="bill_length_mm", y="bill_depth_mm")) +
        geom_smooth(method="lm") + geom_point()


    function add_intercept_column(x::AbstractVector{T}) where {T}
      mat = similar(x, float(T), (length(x), 2))
      fill!(view(mat, :, 1), 1)
      copyto!(view(mat, :, 2), x)
      return mat
    end

    lin_model = GLM.lm(add_intercept_column(penguins.bill_length_mm), penguins.bill_depth_mm)
    x̂ = range(extrema(penguins.bill_length_mm)..., length=100)
    pred = DataFrame(GLM.predict(lin_model, add_intercept_column(x̂); interval=:confidence))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
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
              pred.upper; alpha=0.6
            )
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t, m)

  end