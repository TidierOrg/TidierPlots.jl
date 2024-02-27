"""
    # Points

    The point geom is used to create scatterplots. The scatterplot is most
    useful for displaying the relationship between two continuous variables.
    It can be used to compare one continuous and one categorical variable, or
    two categorical variables, but a variation like `geom_jitter()`,
    `geom_count()`, or `geom_bin_2d()` is usually more
    appropriate. A _bubblechart_ is a scatterplot with a third variable
    mapped to the size of points.

    ## Usage

    geom_point(
        plot::GGPlot,
        data::DataFrame,
        mapping::Aesthetics,
        ... 
    )

    ## Arguments

    All arguments are optional. If `data` and `mapping` are not specified, they will inherit from the GGPlot.

    - `plot:` A GGPlot to modify 
    - `data:` A DataFrame containing the data to be plotted.
    - `mapping:` the names of the columns in the plot DataFrame that will be used to decide where the points are plotted. Create with the `aes` function.
    - `...`: options that are not mapped to a column. Pass supported aesthetics here to fix them to a specific value. 

    ## Aesthetics (Required Aesthetics are in **bold**)

    - **x**
    - **y**
    - size
    - alpha
    - stroke
    - shape
    - colour/color

    ## Examples

    ```
    ggplot(mtcars, @aes(x = WT, y = MPG)) + 
        geom_point()
    ```
    ![](src/assets/geom_point1.png)
"""
geom_point = geom_template("geom_point", ["x", "y"], :Scatter)