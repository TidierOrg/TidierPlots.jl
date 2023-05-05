macro geom_point(exprs...)
    geom_visual = Makie.Scatter
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = nothing
    required_aes = ["x", "y"]

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    check_aes(required_aes, aes_dict)
    
    return geom(geom_visual, aes_dict, args_dict, analysis, plot_data, required_aes)
end

macro geom_smooth(exprs...)
    geom_visual = nothing
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = AlgebraOfGraphics.smooth
    required_aes = ["x", "y"]

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear
        end
    end

    check_aes(required_aes, aes_dict)

    return geom(geom_visual, aes_dict, args_dict,  analysis, plot_data, required_aes)
end

macro geom_col(exprs...)
    geom_visual = nothing
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = AlgebraOfGraphics.frequency
    required_aes = ["x"]

    haskey(args_dict, "data") ? 
        plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"])) :
        plot_data = nothing

    check_aes(required_aes, aes_dict)

    return geom(geom_visual, aes_dict, args_dict,  analysis, plot_data, required_aes)
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

