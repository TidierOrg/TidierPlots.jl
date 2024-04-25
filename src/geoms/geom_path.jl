"""
    geom_line(aes(...), ...)
    geom_line(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order of the variable on the x-axis.

!!! warning "ggplot2 deviation"
    Currently this method does not automatically sort observations in the order of the
    variable on the x-axis as in ggplot2. To solve this, you can compute the sortperm
    of the x-axis variable and order both the `x` and `y` variables according to this
    permutation. E.g.

    ```julia
    p = sortperm(df.x)
    df.xsorted = df.x[p]
    df.ysorted = df.y[p]
    ggplot(df, @aes(x=xsorted, y=ysorted)) + geom_line()
    ```

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_line()
```
"""
geom_line = geom_template("geom_line", ["x", "y"], :Lines)


"""
    geom_step(aes(...), ...)
    geom_step(plot::GGPlot, aes(...), ...)

Represents data as a stairstep plot.

!!! warning "ggplot2 deviation"
    Currently this method does not automatically sort observations in the order of the
    variable on the x-axis as in ggplot2. To solve this, you can compute the sortperm
    of the x-axis variable and order both the `x` and `y` variables according to this
    permutation. E.g.

    ```julia
    p = sortperm(df.x)
    df.xsorted = df.x[p]
    df.ysorted = df.y[p]
    ggplot(df, @aes(x=xsorted, y=ysorted)) + geom_step()
    ```

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Stairs)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
xs = range(0, 2pi, length=30)
df = DataFrame(x = xs, y = sin.(xs))

ggplot(df, @aes(x = x, y = y)) + geom_step()
```
"""
geom_step = geom_template("geom_step", ["x", "y"], :Stairs)


"""
    geom_path(aes(...), ...)
    geom_path(plot::GGPlot, aes(...), ...)

Represents data as connected points in the order in which they appear in the data.

# Arguments

- `plot::GGPlot` (optional): a plot object to add this geom to
- `aes(...)`: the names of the columns in the DataFrame that will be used in the mapping
- `...`: options that are not mapped to a column (passed to Makie.Lines)

# Required Aesthetics

- `x`
- `y`

# Optional Aesthetics (see [`aes`](@ref))

- `color` / `colour`

# Optional Arguments

- `color` / `colour`
- `colormap` / `palette`
- `linestyle` / `linetype`
- `linewidth`
- `alpha`

# Examples

```julia
ggplot(penguins, @aes(x = bill_length_mm, y = bill_depth_mm)) +
    geom_path()
```
"""
geom_path = geom_template("geom_path", ["x", "y"], :Lines)
