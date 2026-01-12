function boxplot_groups(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{Any,Any}, required_aes::Vector{String}, plot_data::DataFrame)

    factor_aes = [aes for (aes, v) in aes_dict if eltype(plot_data[!, v[1]]) <: Union{AbstractString,AbstractChar,CategoricalValue}]

    main_factor_aes = :x

    if :y in factor_aes && !(:x in factor_aes)
        required_aes = ["y", "x"]
        args_dict["orientation"] = :horizontal
        main_factor_aes = :y
    end

    dodge_aes = [aes for aes in factor_aes if aes_dict[aes][1] != aes_dict[main_factor_aes][1]]

    if length(dodge_aes) > 1
        throw(ArgumentError("Too many categorical aes specified, can't select dodge automatically"))
    end

    if length(dodge_aes) != 0
        aes_dict[:dodge] = aes_dict[dodge_aes[1]][1] => identity
    end

    return (aes_dict, args_dict, required_aes, plot_data)
end

function axis_string_as_cat_array(aes_dict::Dict{Symbol,Pair},
    args_dict::Dict{T,Any}, required_aes::Vector{String}, plot_data::DataFrame) where {T}

    plot_data.x = CategoricalArray(plot_data.x)

    return (aes_dict, args_dict, required_aes, plot_data)
end

"""
    geom_boxplot(aes(...), ...)
    geom_boxplot(plot::GGPlot, aes(...), ...)

Compactly displays the distribution of continuous data.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.BoxPlot)

# Required Aesthetics

- `x` (integer or categorical)
- `y` (numeric)

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour` (used in conjunction with `dodge`)
- `dodge`

# Optional Arguments

- `orientation=:vertical`: orientation of box (`:vertical` or `:horizontal`)
- `width=1`
- `gap=0.2`
- `show_notch=false`
- `nothchwidth=0.5`
- `show_median=true`
- `dodge_gap=0.03`

# Examples

```julia
penguins = penguins_data();
ggplot(penguins, @aes(x=species, y=bill_length_mm)) +
    geom_boxplot()

ggplot(penguins, @aes(y=species, x=bill_length_mm)) +
    geom_boxplot()

ggplot(penguins, @aes(x=species, y=bill_length_mm, fill=sex)) +
    geom_boxplot()
```
"""
geom_boxplot = geom_template("geom_boxplot", ["x", "y"], :BoxPlot;
    pre_function=boxplot_groups,
    post_function=axis_string_as_cat_array,
    special_aes=Dict(
        :fill => :color,
        :color => :strokecolor,
        :colour => :strokecolor
    ))

 @testitem "geom_boxplot" setup=[TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_boxplot(@aes(x = species, y = bill_length_mm))

    cat_array = CategoricalArrays.CategoricalArray(penguins.species)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :BoxPlot,
              levelcode.(cat_array),
              penguins.bill_length_mm)
          ]; xticks=(unique(levelcode.(cat_array)),
            unique(cat_array))
        )
      )
    )

    @test plot_images_equal(t, m)

    ae, ar, r, d = TidierPlots.boxplot_groups(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :y => :c => identity,
        :color => :a => identity
      ),
      Dict(),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)
    @test ar["orientation"] == :horizontal

    @test_throws ArgumentError TidierPlots.boxplot_groups(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :y => :c => identity,
        :color => :a => identity,
        :fill => :d => identity
      ),
      Dict(),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"], d=["e", "f"])
    )

  end