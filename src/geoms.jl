macro geom_point(exprs...)
    ##### This section should be consistent across all geoms ####

    # Extract arguments passed inside aes and outside aes into separate dictionaries 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    # If the geom has a data specification, store it in AoG format in geom.data
    # Otherwise draw_ggplot will use the data specified in @ggplot()

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    ##### This section is where the geoms are different ####

    # 1. What are the required aes arguments? They be specified inside this geom
    # or inherited from ggplot(), but if they are not given in either location,
    # the code will error. The order should be the same as expected by AoG's 
    # mapping() function for the plot that will be generated.

    required_aes = ["x", "y"]

    # 2. What optional ggplot aes options are supported, and what is their name 
    # in AoG? 

    optional_aes = Dict("color" => "color",
                        "colour" => "color")

    # 3. If the plot requires a call to AoG's visual() function, geom_visual should
    # contain the Makie function that visual expects as its first argument. If
    # a visual call is not required, this should be set to nothing

    geom_visual = Makie.Scatter

    # 4. If the plot requires a AoG analysis function, that function should be assigned 
    # here. If an AoG analysis is not required, set this to nothing

    analysis = nothing
   
    #### This return statement should not be edited ####

    return geom(geom_visual, aes_dict, args_dict,
        analysis, plot_data,
        required_aes, optional_aes)
end

macro geom_smooth(exprs...)
    ##### This section should be consistent across all geoms ####

    # Extract arguments passed inside aes and outside aes into separate dictionaries 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    # If the geom has a data specification, store it in AoG format in geom.data
    # Otherwise draw_ggplot will use the data specified in @ggplot()

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    ##### This section is where the geoms are different ####

    # 1. What are the required aes arguments? They be specified inside this geom
    # or inherited from ggplot(), but if they are not given in either location,
    # the code will error. The order should be the same as expected by AoG's 
    # mapping() function for the plot that will be generated.

    required_aes = ["x", "y"]

    # 2. What optional ggplot aes options are supported, and what is their name 
    # in AoG? 

    optional_aes = Dict("color" => "color",
                        "colour" => "color")

    # 3. If the plot requires a call to AoG's visual() function, geom_visual should
    # contain the Makie function that visual expects as its first argument. If
    # a visual call is not required, this should be set to nothing

    geom_visual = nothing

    # 4. If the plot requires a AoG analysis function, that function should be assigned 
    # here. If an AoG analysis is not required, set this to nothing

    analysis = AlgebraOfGraphics.smooth

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear
        end
    end

    #### This return statement should not be edited ####

    return geom(geom_visual, aes_dict, args_dict,
        analysis, plot_data,
        required_aes, optional_aes)
end

macro geom_bar(exprs...)
    ##### This section should be consistent across all geoms ####

    # Extract arguments passed inside aes and outside aes into separate dictionaries 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    # If the geom has a data specification, store it in AoG format in geom.data
    # Otherwise draw_ggplot will use the data specified in @ggplot()

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    ##### This section is where the geoms are different ####

    # 1. What are the required aes arguments? They be specified inside this geom
    # or inherited from ggplot(), but if they are not given in either location,
    # the code will error. The order should be the same as expected by AoG's 
    # mapping() function for the plot that will be generated.

    required_aes = ["x"]

    # 2. What optional ggplot aes options are supported, and what is their name 
    # in AoG? 

    optional_aes = Dict("color" => "color",
                        "colour" => "color")

    # 3. If the plot requires a call to AoG's visual() function, geom_visual should
    # contain the Makie function that visual expects as its first argument. If
    # a visual call is not required, this should be set to nothing

    geom_visual = nothing

    # 4. If the plot requires a AoG analysis function, that function should be assigned 
    # here. If an AoG analysis is not required, set this to nothing

    analysis = AlgebraOfGraphics.frequency
    
    #### This return statement should not be edited ####

    return geom(geom_visual, aes_dict, args_dict,
                analysis, plot_data,
                required_aes, optional_aes)
end
# geom_abline

# geom_hline

# geom_vline

# geom_bar

# geom_histogram

# geom_bin_2d

# geom_boxplot

# geom_contour

# geom_density

# geom_errorbar

# geom_errorbarh

# geom_hex

# geom_jitter

# geom_line

# geom_path

# geom_segment

# geom_text 

# geom_label

