function preprocess_image(image, n_size_side)
    img_resized = imresize(image, n_size_side + 1, n_size_side)
    img_resized_gray = Gray.(img_resized)
    return img_resized_gray
end

function reinterpret_bits_as_int_difference_hash(img_resized_gray)

    n_rows, n_cols = size(img_resized_gray)
    n_bits = n_rows * (n_cols-1)

    if n_bits <= 64
        z = zero(UInt64)
    elseif n_bits <= 128
        z = zero(UInt128)
    else
        z = zero(BigInt)
    end

    @inbounds  for j in 1:n_cols-1
        for i in 1:n_rows
            # R[i,j] = X[i,j+1].val > X[i,j].val
            z = (z <<1) | (img_resized_gray[i,j+1].val > img_resized_gray[i,j].val)
        end
    end
    return z
end

function difference_hash(image, n_size_side=8)
    img_resized_gray = preprocess_image(image, n_size_side)
    hash = reinterpret_bits_as_int_difference_hash(img_resized_gray)
    return hash
end

function plot_images_equal(plots...)
    temp_paths = [tempname() * ".png" for p in plots]

    for (path, plot) in zip(temp_paths, plots)
        if typeof(plot) <: Union{TidierPlots.GGPlot,TidierPlots.GGPlotGrid}
            ggsave(path, plot)
        else
            save(path, plot)
        end
    end

    img_hashes = [difference_hash(load(p)) for p in temp_paths]

    return length(unique(img_hashes)) == 1
end

function plot_will_render(plot)
    temp_path = tempname() * ".png"
    ggsave(plot, temp_path)
    return true
end
