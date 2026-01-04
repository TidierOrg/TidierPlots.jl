"""
    geom_hline(aes(...), ...)
    geom_hline(plot::GGPlot, aes(...), ...)

Plot a horizontal line at the given y-intercept(s).

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.HLines)

# Required Aesthetics

- NA

# Optional Aesthetics (see [`aes`](@ref))

- `yintercept(s)`
- `color` / `colour`

# Optional Arguments

- `yintercept(s)`
- `color` / `colour`
- `linewidth`
- `linestyle` / `linetype`
- `colormap` / `palette`
- `alpha`

# Examples

```julia
# Plot only a single y-intercept
ggplot() + geom_hline(yintercept = 3)

# Plot multiple y-intercepts
ggplot() + geom_hline(yintercept = [-1, 4])

# Plot multiple y-intercepts mapped to a column
df = DataFrame(y = rand(4))
ggplot(df, @aes(yintercept = y)) + geom_hline()
```
"""
function geom_hline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_hline"

    if haskey(args_dict, "yintercept")
        yint_values = args_dict["yintercept"]
        # Convert Date/DateTime to numeric values
        if yint_values isa Dates.Date
            yint_values = Float64(Dates.value(yint_values))
        elseif yint_values isa Dates.DateTime
            yint_values = Float64(Dates.value(yint_values))
        elseif yint_values isa AbstractVector && length(yint_values) > 0
            if yint_values[1] isa Dates.Date
                yint_values = Float64.(Dates.value.(yint_values))
            elseif yint_values[1] isa Dates.DateTime
                yint_values = Float64.(Dates.value.(yint_values))
            end
        end
        args_dict["data"] = DataFrame(Numeric = yint_values)
        aes_dict[:yintercept] = :Numeric => identity
    end

    return build_geom(aes_dict, args_dict,
        ["yintercept"], # required aesthetics
        :HLines) # function for visual layer
end

@testitem "geom_hline" setup = [TidierPlotsSetup] begin
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

"""
    geom_vline(aes(...), ...)
    geom_vline(plot::GGPlot, aes(...), ...)

Plot a horizontal line at the given y-intercept(s).

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.VLines)

# Required Aesthetics

- NA

# Optional Aesthetics (see [`aes`](@ref))

- `xintercept(s)`
- `color` / `colour`

# Optional Arguments

- `xintercept(s)`
- `color` / `colour`
- `linewidth`
- `linestyle` / `linetype`
- `colormap` / `palette`
- `alpha`

# Examples

```julia
# Plot only a single x-intercept
ggplot() + geom_vline(xintercept = 3)

# Plot multiple x-intercepts
ggplot() + geom_vline(xintercept = [-1, 4])

# Plot multiple x-intercepts mapped to a column
df = DataFrame(x = rand(4))
ggplot(df, @aes(xintercept = x)) + geom_vline()
```
"""
function geom_vline(args...; kwargs...)
    aes_dict, args_dict = extract_aes(args, kwargs)

    args_dict["geom_name"] = "geom_vline"

    if haskey(args_dict, "xintercept")
        xint_values = args_dict["xintercept"]
        # Convert Date/DateTime to numeric values
        if xint_values isa Dates.Date
            xint_values = Float64(Dates.value(xint_values))
        elseif xint_values isa Dates.DateTime
            xint_values = Float64(Dates.value(xint_values))
        elseif xint_values isa AbstractVector && length(xint_values) > 0
            if xint_values[1] isa Dates.Date
                xint_values = Float64.(Dates.value.(xint_values))
            elseif xint_values[1] isa Dates.DateTime
                xint_values = Float64.(Dates.value.(xint_values))
            end
        end
        args_dict["data"] = DataFrame(Numeric = xint_values)
        aes_dict[:xintercept] = :Numeric => identity
    end

    return build_geom(aes_dict, args_dict,
        ["xintercept"], # required aesthetics
        :VLines) # function for visual layer
end

function geom_hline(plot::GGPlot, args...; kwargs...)
    return plot + geom_hline(args...; kwargs...)
end

function geom_vline(plot::GGPlot, args...; kwargs...)
    return plot + geom_vline(args...; kwargs...)
end


  @testitem "geom_vline" setup = [TidierPlotsSetup] begin
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