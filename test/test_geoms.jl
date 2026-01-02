@testset verbose = true "geoms" begin

  @testset "geom_point" begin
    t = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm))

    t2 = ggplot() +
         geom_point(penguins, @aes(x = bill_length_mm, y = bill_depth_mm))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Scatter,
              penguins.bill_length_mm,
              penguins.bill_depth_mm)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)
    @test plot_images_equal(t2, m)

    t3 = ggplot() +
         geom_point(penguins,
      @aes(x = bill_length_mm, y = bill_depth_mm, color = sex))
    t4 = ggplot() +
         geom_point(penguins,
      @aes(x = bill_length_mm, y = bill_depth_mm, fill = sex))

    @test plot_images_equal(t3, t4)

    # Note: In geom_point, color maps to strokecolor and fill maps to color
    # So guides must use the Makie-level names after translation
    t5 = ggplot(penguins) +
         geom_point(
           @aes(x = bill_length_mm,
             y = bill_depth_mm,
             color = sex,
             fill = species),
           strokewidth=1) + guides(strokecolor="none", color="none")

    cat_species = CategoricalArrays.CategoricalArray(penguins.species)
    cat_sex = CategoricalArrays.CategoricalArray(penguins.sex)

    m2 = Makie.plot(Makie.SpecApi.GridLayout(Makie.SpecApi.Axis(
      plots=[Makie.PlotSpec(
        :Scatter,
        penguins.bill_length_mm,
        penguins.bill_depth_mm;
        color=TidierPlots._default_discrete_palette(cat_species),
        strokecolor=TidierPlots._default_discrete_palette(cat_sex),
        strokewidth=1)
      ]
    )))

    @test plot_images_equal(t5, m2)

    # Test handle_point_color_and_fill with static fill only (no color arg)
    t_fill_only = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm), fill=:red)
    @test plot_will_render(t_fill_only)

    # Test handle_point_color_and_fill with both static fill and color args
    t_fill_and_color = ggplot(penguins) +
        geom_point(@aes(x = bill_length_mm, y = bill_depth_mm), fill=:red, color=:blue)
    @test plot_will_render(t_fill_and_color)

    # Test direct handle_point_color_and_fill function with fill arg only
    ae1, ar1, r1, d1 = TidierPlots.handle_point_color_and_fill(
      Dict{Symbol,Pair}(:x => :x => identity, :y => :y => identity),
      Dict{Any,Any}("fill" => :red),
      ["x", "y"],
      DataFrame(x=[1,2,3], y=[1,2,3])
    )
    @test haskey(ar1, "color")
    @test ar1["color"] == :red
    @test !haskey(ar1, "fill")

    # Test direct handle_point_color_and_fill function with both fill and color args
    ae2, ar2, r2, d2 = TidierPlots.handle_point_color_and_fill(
      Dict{Symbol,Pair}(:x => :x => identity, :y => :y => identity),
      Dict{Any,Any}("fill" => :red, "color" => :blue),
      ["x", "y"],
      DataFrame(x=[1,2,3], y=[1,2,3])
    )
    @test ar2["color"] == :red  # fill becomes color
    @test ar2["strokecolor"] == :blue  # color becomes strokecolor
    @test !haskey(ar2, "fill")

    # Test with "colour" spelling instead of "color"
    ae3, ar3, r3, d3 = TidierPlots.handle_point_color_and_fill(
      Dict{Symbol,Pair}(:x => :x => identity, :y => :y => identity),
      Dict{Any,Any}("fill" => :green, "colour" => :orange),
      ["x", "y"],
      DataFrame(x=[1,2,3], y=[1,2,3])
    )
    @test ar3["colour"] == :green  # fill becomes colour
    @test ar3["strokecolor"] == :orange  # colour becomes strokecolor
  end


  @testset "geom_bar" begin
    t = ggplot(penguins) +
        geom_bar(@aes(x = species))

    penguins_count = @chain penguins begin
      groupby(:species)
      @summarize(count = n())
      @arrange(species)
    end

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :BarPlot,
              penguins_count.count)
          ]; xticks=(1:3, penguins_count.species)
        )
      )
    )

    @test plot_images_equal(t, m)

    penguins_count_by_sex = @chain penguins begin
      groupby([:species, :sex])
      @summarize(count = n())
      @arrange(species)
      @ungroup
    end

    # In geom_bar, fill maps to color. Use guides to suppress the legend for comparison
    t = ggplot(penguins) +
        geom_bar(@aes(x = species, fill = sex), position="dodge") +
        guides(color="none")

    cat_sex = TidierPlots._default_discrete_palette(levelcode.(CategoricalArray(penguins_count_by_sex.sex)))
    cat_spec = levelcode.(CategoricalArray(penguins_count_by_sex.species))
    dodge = levelcode.(CategoricalArray(penguins_count_by_sex.sex))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :BarPlot,
              cat_spec,
              penguins_count_by_sex.count;
              dodge=dodge,
              color=cat_sex)
          ]; xticks=(1:3, unique(penguins_count_by_sex.species))
        )
      )
    )

    @test plot_images_equal(t, m)

    @test_throws ArgumentError TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :y => :c => identity,
        :color => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :color => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :colour => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :group => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :fill => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:fill] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :color => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "stack"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :colour => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "stack"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :group => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "stack"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:stack] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :fill => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "stack"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:fill] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :color => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "dodge"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :colour => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "dodge"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :group => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "dodge"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :x => :b => identity,
        :fill => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "dodge"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)

    ae, ar, r, df = TidierPlots.handle_position(
      Dict{Symbol,Pair}(
        :y => :b => identity,
        :fill => :a => identity
      ),
      Dict{Any,Any}("geom_name" => "geom_bar", "position" => "dodge"),
      ["x"],
      DataFrame(a=["a", "b"], b=[1, 2], c=["c", "d"])
    )

    @test ae[:dodge] == (:a => identity)
    @test ar["direction"] == "x"
    @test r == ["y", "x"]
  end

  @testset "geom_col" begin
    penguins_count = @chain penguins begin
      groupby(:species)
      @summarize(count = n())
      @arrange(species)
    end

    t = ggplot(penguins_count) +
        geom_col(@aes(x = species, y = count))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :BarPlot,
              penguins_count.count)
          ]; xticks=(1:3, penguins_count.species)
        )
      )
    )

    @test plot_images_equal(t, m)
  end

  @testset "geom_path" begin
    t = ggplot(penguins) +
        geom_path(@aes(x = bill_length_mm, y = bill_depth_mm))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Lines,
              penguins.bill_length_mm,
              penguins.bill_depth_mm)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)
  end

  @testset "geom_line" begin
    t = ggplot(penguins) +
        geom_line(@aes(x = bill_length_mm, y = bill_depth_mm))

    perm = sortperm(penguins.bill_length_mm)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Lines,
              penguins.bill_length_mm[perm],
              penguins.bill_depth_mm[perm])
          ]
        )
      )
    )

    @test plot_images_equal(t, m)
  end

  @testset "geom_step" begin
    xs = collect(rand(30) * 2pi)
    df = DataFrame(x=xs, y=sin.(xs))

    perm = sortperm(df.x)

    t = ggplot(df, @aes(x = x, y = y)) + geom_step()

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Stairs,
              df.x[perm],
              df.y[perm])
          ]; xlabel="x", ylabel="y"
        )
      )
    )

    @test plot_images_equal(t, m)
  end

  @testset "geom_boxplot" begin
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

  @testset "geom_violin" begin
    t = ggplot(penguins) +
        geom_violin(@aes(x = species, y = bill_length_mm))

    cat_array = CategoricalArrays.CategoricalArray(penguins.species)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Violin,
              levelcode.(cat_array),
              penguins.bill_length_mm)
          ]; xticks=(unique(levelcode.(cat_array)),
            unique(cat_array))
        )
      )
    )

    @test plot_images_equal(t, m)
  end

  @testset "geom_hist" begin
    t = ggplot(penguins) +
        geom_histogram(@aes(x = bill_length_mm))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Hist,
              penguins.bill_length_mm)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    # Test handle_histogram with center parameter
    df_hist = DataFrame(x = [0.5, 1.5, 2.5, 3.5, 4.5, 5.5])
    t_center = ggplot(df_hist, @aes(x = x)) + geom_histogram(binwidth=1, center=0)
    @test plot_will_render(t_center)

    # Test handle_histogram with boundary parameter
    t_boundary = ggplot(df_hist, @aes(x = x)) + geom_histogram(binwidth=1, boundary=0)
    @test plot_will_render(t_boundary)

    # Test handle_histogram with binwidth only (no center/boundary)
    t_binwidth = ggplot(df_hist, @aes(x = x)) + geom_histogram(binwidth=1)
    @test plot_will_render(t_binwidth)

    # Test handle_histogram when bins is already a vector (should skip processing)
    t_bins_vector = ggplot(df_hist, @aes(x = x)) + geom_histogram(bins=[0, 2, 4, 6])
    @test plot_will_render(t_bins_vector)

    # Test handle_histogram direct function with center
    ae, ar, r, d = TidierPlots.handle_histogram(
      Dict{Symbol,Pair}(:x => :x => identity),
      Dict{Any,Any}("center" => 0, "binwidth" => 1),
      ["x"],
      df_hist
    )
    @test haskey(ar, "bins")
    @test ar["bins"] isa AbstractVector
    @test !haskey(ar, "center")
    @test !haskey(ar, "binwidth")

    # Test handle_histogram direct function with boundary
    ae2, ar2, r2, d2 = TidierPlots.handle_histogram(
      Dict{Symbol,Pair}(:x => :x => identity),
      Dict{Any,Any}("boundary" => 0, "binwidth" => 1),
      ["x"],
      df_hist
    )
    @test haskey(ar2, "bins")
    @test ar2["bins"] isa AbstractVector
    @test !haskey(ar2, "boundary")

    # Test handle_histogram with center but no explicit binwidth (uses bins count)
    ae3, ar3, r3, d3 = TidierPlots.handle_histogram(
      Dict{Symbol,Pair}(:x => :x => identity),
      Dict{Any,Any}("center" => 0, "bins" => 5),
      ["x"],
      df_hist
    )
    @test haskey(ar3, "bins")
    @test ar3["bins"] isa AbstractVector

    # Test handle_histogram when bins is already a vector (early return)
    ae4, ar4, r4, d4 = TidierPlots.handle_histogram(
      Dict{Symbol,Pair}(:x => :x => identity),
      Dict{Any,Any}("center" => 0, "bins" => [0.0, 1.0, 2.0]),
      ["x"],
      df_hist
    )
    @test ar4["bins"] == [0.0, 1.0, 2.0]  # Should remain unchanged

    # Test binwidth only (no center or boundary)
    ae5, ar5, r5, d5 = TidierPlots.handle_histogram(
      Dict{Symbol,Pair}(:x => :x => identity),
      Dict{Any,Any}("binwidth" => 2),
      ["x"],
      df_hist
    )
    @test haskey(ar5, "bins")
    @test !haskey(ar5, "binwidth")
  end

  @testset "geom_density" begin
    t = ggplot(penguins, @aes(x = body_mass_g)) +
        geom_density()

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        [Makie.SpecApi.Axis(
        plots=[
          Makie.PlotSpec(
            :Density,
            penguins.body_mass_g)]; xlabel="body_mass_g"
      )]
      )
    )

    @test plot_images_equal(t, m)

    t1 = ggplot(penguins) +
         geom_density(aes(
        x=:bill_length_mm,
        color=:sex,
        fill=:species
      ), strokewidth=1)

    t2 = ggplot(penguins) +
         geom_density(aes(
      x=:bill_length_mm,
      color=:sex,
      fill=:species
    ))

    @test plot_images_equal(t1, t2)
  end

  @testset "geom_errorbar" begin
    categories = [1, 2, 3, 4]
    n = length(categories)

    mean_values = rand(n)  # Random mean values for demonstration
    errors = rand(n) / 2   # Random error values for demonstration

    LowerBound = mean_values .- errors
    UpperBound = mean_values .+ errors

    df_errorbar = DataFrame(
      cat_numeric=categories,
      MeanValue=mean_values,
      LowerBound=LowerBound,
      UpperBound=UpperBound)

    t = ggplot(df_errorbar, @aes(x = cat_numeric, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) +
        geom_point() + # to show the mean value
        geom_errorbar() # width of the horizontal line at the top and bottom of the error bar

    t2 = @chain ggplot(df_errorbar, @aes(x = cat_numeric, y = MeanValue, ymin = LowerBound, ymax = UpperBound)) begin
      geom_point()
      geom_errorbar()
    end

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Scatter,
              df_errorbar.cat_numeric,
              df_errorbar.MeanValue),
            Makie.PlotSpec(
              :Rangebars,
              df_errorbar.cat_numeric,
              df_errorbar.LowerBound,
              df_errorbar.UpperBound)
          ]; xlabel="cat_numeric", ylabel="MeanValue"
        )
      )
    )

    @test plot_images_equal(t, m)
    @test plot_images_equal(t2, m)

    t3 = @chain ggplot(df_errorbar, @aes(y = cat_numeric, x = MeanValue, xmin = LowerBound, xmax = UpperBound)) begin
      geom_point()
      geom_errorbarh()
    end

    t4 = ggplot(df_errorbar, @aes(y = cat_numeric, x = MeanValue, xmin = LowerBound, xmax = UpperBound)) +
         geom_point() + # to show the mean value
         geom_errorbarh()

    m2 = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Scatter,
              df_errorbar.MeanValue,
              df_errorbar.cat_numeric),
            Makie.PlotSpec(
              :Rangebars,
              df_errorbar.cat_numeric,
              df_errorbar.LowerBound,
              df_errorbar.UpperBound; direction=:x)
          ]; xlabel="cat_numeric", ylabel="MeanValue"
        )
      )
    )

    @test plot_images_equal(t3, m2)
    @test plot_images_equal(t4, m2)

  end

  @testset "geom_smooth" begin
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

  @testset "geom_text" begin
    t = ggplot(penguins) +
        geom_text(aes(x=:bill_length_mm, y=:bill_depth_mm, text=:species))

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Text,
              penguins.bill_length_mm,
              penguins.bill_depth_mm;
              text=String.(penguins.species))
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

  end

  @testset "geom_hline" begin
    yint = 2.5

    t = ggplot(penguins) +
        geom_hline(yintercept=yint)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :HLines,
              yint
            )
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_hline(ggplot(penguins), yintercept=yint)

    @test plot_images_equal(t, t2)

    # Test with Date yintercept
    date_val = Dates.Date(2024, 1, 15)
    t_date = ggplot() + geom_hline(yintercept=date_val)
    @test plot_will_render(t_date)

    # Test with DateTime yintercept
    datetime_val = Dates.DateTime(2024, 1, 15, 12, 30, 0)
    t_datetime = ggplot() + geom_hline(yintercept=datetime_val)
    @test plot_will_render(t_datetime)

    # Test with vector of Date values
    date_vec = [Dates.Date(2024, 1, 1), Dates.Date(2024, 6, 1), Dates.Date(2024, 12, 1)]
    t_date_vec = ggplot() + geom_hline(yintercept=date_vec)
    @test plot_will_render(t_date_vec)

    # Test with vector of DateTime values
    datetime_vec = [Dates.DateTime(2024, 1, 1), Dates.DateTime(2024, 6, 1)]
    t_datetime_vec = ggplot() + geom_hline(yintercept=datetime_vec)
    @test plot_will_render(t_datetime_vec)

    # Test with multiple numeric yintercepts
    t_multi = ggplot() + geom_hline(yintercept=[1.0, 2.0, 3.0])
    @test plot_will_render(t_multi)
  end

  @testset "geom_vline" begin
    xint = 2.5

    t = ggplot() +
        geom_vline(xintercept=xint)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :VLines,
              xint
            )
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_vline(ggplot(penguins), xintercept=xint)

    @test plot_images_equal(t, t2)

    # Test with Date xintercept
    date_val = Dates.Date(2024, 1, 15)
    t_date = ggplot() + geom_vline(xintercept=date_val)
    @test plot_will_render(t_date)

    # Test with DateTime xintercept
    datetime_val = Dates.DateTime(2024, 1, 15, 12, 30, 0)
    t_datetime = ggplot() + geom_vline(xintercept=datetime_val)
    @test plot_will_render(t_datetime)

    # Test with vector of Date values
    date_vec = [Dates.Date(2024, 1, 1), Dates.Date(2024, 6, 1), Dates.Date(2024, 12, 1)]
    t_date_vec = ggplot() + geom_vline(xintercept=date_vec)
    @test plot_will_render(t_date_vec)

    # Test with vector of DateTime values
    datetime_vec = [Dates.DateTime(2024, 1, 1), Dates.DateTime(2024, 6, 1)]
    t_datetime_vec = ggplot() + geom_vline(xintercept=datetime_vec)
    @test plot_will_render(t_datetime_vec)

    # Test with multiple numeric xintercepts
    t_multi = ggplot() + geom_vline(xintercept=[1.0, 2.0, 3.0])
    @test plot_will_render(t_multi)
  end

  @testset "geom_rainclouds" begin
    t = ggplot(penguins) +
        geom_rainclouds(@aes(x = species, y = bill_length_mm))

    cat_array = CategoricalArrays.CategoricalArray(penguins.species)

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :RainClouds,
              levelcode.(cat_array),
              penguins.bill_length_mm)
          ]; xticks=(unique(levelcode.(cat_array)),
            unique(cat_array))
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_rainclouds(ggplot(penguins),
      @aes(x = species, y = bill_length_mm))

    @test plot_images_equal(t, t2)
  end

  @testset "geom_contour" begin
    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_contour()
    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d.x,
              d.y,
              d.z;
            )
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )
    @test plot_images_equal(t, m)
  end

  @testset "geom_contour_filled" begin
    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_contour_filled()
    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contourf,
              d.x,
              d.y,
              d.z;
              levels=10)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )
    @test plot_images_equal(t, m)
  end


  @testset "geom_density_2d" begin
    ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_density2d(breaks=10)
    @test_throws ArgumentError TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity
      ),
      Dict(),
      ["x"],
      @chain penguins begin
        @rename(x = bill_length_mm)
      end
    )

    @test_warn "Equal x and y aesthetics detected. This may not be intended." TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_length_mm => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @mutate(x = bill_length_mm, y = bill_length_mm, group = 1)
      end
    )


    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_density_2d(breaks=10)

    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d.x,
              d.y,
              d.z;
              levels=10)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t, m)


    t2 = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm, group = species)) +
         geom_density_2d()

    ae2, ar2, r2, d2 = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm, group = species)
      end
    )

    m2 = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contour,
              d2.x[d2.group.==g],
              d2.y[d2.group.==g],
              d2.z[d2.group.==g],
            ) for g in unique(d2.group)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )

    @test plot_images_equal(t2, m2)

  end


  @testset "geom_density_2d_filled" begin
    ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_density2d_filled()

    t = ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
        geom_density_2d_filled()

    ae, ar, r, d = TidierPlots.stat_contour(
      Dict{Symbol,Pair}(
        :x => :bill_length_mm => identity,
        :y => :bill_depth_mm => identity,
        :group => :species => identity
      ),
      Dict(),
      ["x", "y"],
      @chain penguins begin
        @rename(x = bill_length_mm, y = bill_depth_mm)
        @mutate(group = 1)
      end
    )

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Contourf,
              d.x,
              d.y,
              d.z)
          ]; xlabel="bill_length_mm", ylabel="bill_depth_mm"
        )
      )
    )


    @test plot_images_equal(t, m)

  end

  @testset "geom_jitter" begin
    t = ggplot(penguins) +
      geom_jitter(@aes(x = species, y = bill_length_mm), jitter_width = 0, jitter_height = 0)

      cat_array = CategoricalArrays.CategoricalArray(penguins.species)

      m = Makie.plot(
          Makie.SpecApi.GridLayout(
              Makie.SpecApi.Axis(
                  plots = [
                      Makie.PlotSpec(:Scatter,
                        levelcode.(cat_array),
                        penguins.bill_length_mm,
                        )
                  ]; xticks=(unique(levelcode.(cat_array)),
                  unique(cat_array))
              )
          )
      )

      @test plot_images_equal(t, m)
  end

  @testset "geom_segment" begin
    df_segment = DataFrame(
      x = [1, 2, 3],
      y = [1, 2, 1],
      xend = [2, 3, 4],
      yend = [2, 1, 2]
    )

    t = ggplot(df_segment, @aes(x = x, y = y, xend = xend, yend = yend)) +
        geom_segment() + labs(x = "", y = "")

    # Makie's LineSegments expects interleaved points: [start1, end1, start2, end2, ...]
    x_interleaved = Float64[1, 2, 2, 3, 3, 4]
    y_interleaved = Float64[1, 2, 2, 1, 1, 2]

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :LineSegments,
              x_interleaved,
              y_interleaved; color = :black)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    # Test alternative syntax with geom receiving plot
    t2 = geom_segment(ggplot(df_segment), @aes(x = x, y = y, xend = xend, yend = yend)) + labs(x = "", y = "")

    @test plot_images_equal(t, t2)
  end

  @testset "geom_ribbon" begin
    xs = collect(range(0, 2pi, length=30))
    df_ribbon = DataFrame(x = xs, ymin = sin.(xs) .- 0.5, ymax = sin.(xs) .+ 0.5)

    t = ggplot(df_ribbon, @aes(x = x, ymin = ymin, ymax = ymax)) + geom_ribbon()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_ribbon(ggplot(df_ribbon), @aes(x = x, ymin = ymin, ymax = ymax))
    @test plot_will_render(t2)
  end

  @testset "geom_area" begin
    xs = collect(range(0, 2pi, length=30))
    df_area = DataFrame(x = xs, y = sin.(xs) .+ 1.5)

    t = ggplot(df_area, @aes(x = x, y = y)) + geom_area()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_area(ggplot(df_area), @aes(x = x, y = y))
    @test plot_will_render(t2)
  end

  @testset "geom_linerange" begin
    df_linerange = DataFrame(
      x = [1, 2, 3, 4],
      ymin = [1.0, 2.0, 1.5, 2.5],
      ymax = [3.0, 4.0, 3.5, 4.5]
    )

    t = ggplot(df_linerange, @aes(x = x, ymin = ymin, ymax = ymax)) + geom_linerange()

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(
              :Rangebars,
              df_linerange.x,
              df_linerange.ymin,
              df_linerange.ymax;
              color=:black)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_linerange(ggplot(df_linerange), @aes(x = x, ymin = ymin, ymax = ymax))
    @test plot_images_equal(t, t2)
  end

  @testset "geom_pointrange" begin
    df_pointrange = DataFrame(
      x = [1, 2, 3, 4],
      y = [2.0, 3.0, 2.5, 3.5],
      ymin = [1.0, 2.0, 1.5, 2.5],
      ymax = [3.0, 4.0, 3.5, 4.5]
    )

    t = ggplot(df_pointrange, @aes(x = x, y = y, ymin = ymin, ymax = ymax)) + geom_pointrange()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_pointrange(ggplot(df_pointrange), @aes(x = x, y = y, ymin = ymin, ymax = ymax))
    @test plot_will_render(t2)
  end

  @testset "geom_polygon" begin
    df_polygon = DataFrame(
      x = [0.0, 1.0, 0.5],
      y = [0.0, 0.0, 1.0]
    )

    t = ggplot(df_polygon, @aes(x = x, y = y)) + geom_polygon()

    # Test that plot renders successfully
    @test plot_will_render(t)

    # Test alternative syntax
    t2 = geom_polygon(ggplot(df_polygon), @aes(x = x, y = y))
    @test plot_will_render(t2)
  end

  @testset "geom_rect" begin
    df_rect = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0]
    )

    t = ggplot(df_rect, @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) + geom_rect()

    # First rectangle vertices
    points1 = [Point2f(1, 1), Point2f(2, 1), Point2f(2, 3), Point2f(1, 3)]
    # Second rectangle vertices
    points2 = [Point2f(3, 2), Point2f(4, 2), Point2f(4, 4), Point2f(3, 4)]

    m = Makie.plot(
      Makie.SpecApi.GridLayout(
        Makie.SpecApi.Axis(
          plots=[
            Makie.PlotSpec(:Poly, points1; color=:black),
            Makie.PlotSpec(:Poly, points2; color=:black)
          ]
        )
      )
    )

    @test plot_images_equal(t, m)

    t2 = geom_rect(ggplot(df_rect), @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax))
    @test plot_images_equal(t, t2)

    # Test handle_rect direct function call
    ae, ar, r, d = TidierPlots.handle_rect(
      Dict{Symbol,Pair}(
        :xmin => :xmin => identity,
        :xmax => :xmax => identity,
        :ymin => :ymin => identity,
        :ymax => :ymax => identity
      ),
      Dict{Any,Any}(),
      ["xmin", "xmax", "ymin", "ymax"],
      df_rect
    )
    @test haskey(ae, :points)
    @test haskey(ae, :group)
    @test r == ["points"]
    @test nrow(d) == 8  # 2 rects * 4 vertices each
    @test haskey(d, :points)
    @test haskey(d, :rect_group)
    @test d.rect_group[1:4] == [1, 1, 1, 1]
    @test d.rect_group[5:8] == [2, 2, 2, 2]

    # Test with additional column that should be duplicated
    df_rect_with_extra = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0],
      label = ["A", "B"]
    )
    ae2, ar2, r2, d2 = TidierPlots.handle_rect(
      Dict{Symbol,Pair}(
        :xmin => :xmin => identity,
        :xmax => :xmax => identity,
        :ymin => :ymin => identity,
        :ymax => :ymax => identity
      ),
      Dict{Any,Any}(),
      ["xmin", "xmax", "ymin", "ymax"],
      df_rect_with_extra
    )
    @test d2.label[1:4] == ["A", "A", "A", "A"]
    @test d2.label[5:8] == ["B", "B", "B", "B"]

    # Test geom_rect with fill aesthetic
    df_rect_fill = DataFrame(
      xmin = [1.0, 3.0],
      xmax = [2.0, 4.0],
      ymin = [1.0, 2.0],
      ymax = [3.0, 4.0],
      group = ["A", "B"]
    )
    t_fill = ggplot(df_rect_fill, @aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = group)) + geom_rect()
    @test plot_will_render(t_fill)
  end

end
