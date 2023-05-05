macro geom_point(exprs...)
    geom_visual = :Scatter
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = nothing
    required_aes = ["x", "y"]

    check_aes(required_aes, aes_dict)
    
    return geom(geom_visual, aes_dict, args_dict, nothing, required_aes)
end

macro geom_smooth(exprs...)
    geom_visual = nothing
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = AlgebraOfGraphics.smooth
    required_aes = ["x", "y"]

    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear
        end
    end

    check_aes(required_aes, aes_dict)

    return geom(geom_visual, aes_dict, args_dict, analysis, required_aes)
end

# geom_abline

# geom_hline

# geom_vline

# geom_bar

# geom_col

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

