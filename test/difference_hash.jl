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

function plot_images_equal(tidier, makie)
    tidierpath = tempname() * ".png"
    makiepath = tempname() * ".png"

    ggsave(tidierpath, tidier)
    save(makiepath, makie)

    t_img = load(tidierpath)
    m_img = load(makiepath)
    
    return difference_hash(t_img) == difference_hash(m_img)
end