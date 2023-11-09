


<a id='Index'></a>

<a id='Index-1'></a>

## Index

- [`TidierPlots.geom_density`](reference.md#TidierPlots.geom_density)
- [`TidierPlots.geom_point`](reference.md#TidierPlots.geom_point)


<a id='Reference-Exported-functions'></a>

<a id='Reference-Exported-functions-1'></a>

## Reference - Exported functions

<a id='TidierPlots.geom_density' href='#TidierPlots.geom_density'>#</a>
**`TidierPlots.geom_density`** &mdash; *Function*.



```julia
@geom_density(aes(...), ...)

Represent data as a smooth density curve. 

# Arguments

- `aes(...)`: the names of the columns in the plot DataFrame and their corresponding aesthetic.
- `...`: options that are not mapped to a column 

# Required Aesthetics

- x

# Supported Optional Aesthetics

- alpha
- stroke
- colour/color

# Supported Options

- alpha
- stroke
- colour/color
```

<a id='TidierPlots.geom_point' href='#TidierPlots.geom_point'>#</a>
**`TidierPlots.geom_point`** &mdash; *Function*.



```julia
@geom_point(aes(...), ...)

Represent data as points. 

# Arguments

- `aes(...)`: the names of the columns in the plot DataFrame that will be used to decide where the points are plotted.
- `...`: options that are not mapped to a column 

# Required Aesthetics

- x
- y

# Supported Optional Aesthetics

- size
- alpha
- stroke
- shape
- colour/color

# Supported Options

- size
- alpha
- stroke
- shape
- colour/color
```


<a id='Reference-Internal-functions'></a>

<a id='Reference-Internal-functions-1'></a>

## Reference - Internal functions

