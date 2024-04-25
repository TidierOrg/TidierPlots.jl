# TODO: add :auto accuracy heuristic to determine how many digits are needed to distinguish numbers
function label_bytes(;units=:si, kwargs...)
    si_scales = [
        "YB" => 10.0 ^24,
        "ZB" => 10.0 ^21,
        "EB" => 10.0 ^18,
        "PB" => 10.0 ^15,
        "TB" => 10.0 ^12,
        "GB" => 10.0 ^9 ,
        "MB" => 10.0 ^6 ,
        "KB" => 10.0 ^3,
        "B"  => 10.0 ^0
    ]
    binary_scales = [
        "YiB" => 1024.0 ^8,
        "ZiB" => 1024.0 ^7,
        "EiB" => 1024.0 ^6,
        "PiB" => 1024.0 ^5,
        "TiB" => 1024.0 ^4,
        "GiB" => 1024.0 ^3,
        "MiB" => 1024.0 ^2,
        "KiB" => 1024.0 ^1,
        "B"   => 1024.0 ^0
    ]
    if units == :si
        scales = si_scales
    elseif units == :binary
        scales = binary_scales
    else
        for (sym, mag) in vcat(si_scales, binary_scales)
            if string(units) == sym
                scales = [
                    sym => mag
                ]
            end
        end
    end
    function labeler(value::Real)
        bval = big(value)
        for (sym, mag) in scales
            if abs(bval) >= mag
                bval /= mag
                lnum = label_number(; suffix=" $sym", kwargs...)
                return lnum(bval)
            end
        end
        sym,mag = scales[1]
        lnum = label_number(; suffix=" $sym", kwargs...)
        return lnum(bval / mag)
    end
    return (values) -> labeler.(values)
end

function label_currency(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(; prefix="\$", kwargs...)
        return lnum(float(value))
    end
    return (values) -> labeler.(values)
end

# TODO: work for different timezones? May need TimeZones.jl
function label_date(;format="m/d/Y")
    function labeler(value::T) where T <: TimeType
        Dates.format(value, format)
    end
    return (values) -> labeler.(values)
end

function label_log(;base=10, kwargs...)
    function labeler(value::Real)
        exp = log(base, value)
        lnum = label_number(; prefix="$base^", kwargs...)
        return lnum(exp)
    end
    return (values) -> labeler.(values)
end

function label_number(;
    precision=2,
    scale=1,
    prefix="",
    suffix="",
    decimal_mark=".",
    comma_mark=",",
    style_positive=:none,
    style_negative=:hyphen,
    kwargs...
)
    if style_positive == :none
        pos_mark = ""
    elseif style_positive == :plus
        pos_mark = "+"
    elseif style_positive == :space
        pos_mark = " "
    else
        error("$style_positive is not a valid positive number style. Choose between [:none, :plus, :space]")
    end
    if style_negative == :hyphen
        neg_mark = ""
    elseif style_negative == :parens
        neg_mark = "("
    else
        error("$style_negative is not a valid negative number style. Choose between [:hyphen, :minus, :parens]")
    end
    function labeler(value::Real)
        label = format(
            float(scale*value);
            precision=precision,
            stripzeros=true,
            commas=true,
            suffix=suffix,
            kwargs...
        )
        label = replace(label, "." => decimal_mark, "," => comma_mark)
        if value < 0
            if neg_mark == "("
                cut_label = label[2:(length(label)-length(suffix))]
                label = "($cut_label)$suffix"
            else
                label = neg_mark * label
            end
        else
            label = pos_mark * label
        end
        label = prefix*label
        return label
    end
    return (values) -> labeler.(values)
end

function label_ordinal(;kwargs...)
    labels = Dict(
        0 => "th",
        1 => "st",
        2 => "nd",
        3 => "rd",
        4 => "th",
        5 => "th",
        6 => "th",
        7 => "th",
        8 => "th",
        9 => "th",
        10 => "th",
        11 => "th",
        12 => "th",
        13 => "th",
        14 => "th",
        15 => "th",
        16 => "th",
        17 => "th",
        18 => "th",
        19 => "th",
    )
    function labeler(value::Real)
        ivalue = round(Int, value)
        twenties = ivalue % 20
        lnum = label_number(; suffix=labels[twenties], kwargs...)
        return lnum(ivalue)
    end
    return (values) -> labeler.(values)
end

function label_percent(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(;scale=100, suffix="%", kwargs...)
        return lnum(value)
    end
    return (values) -> labeler.(values)
end

# TODO: Option to add "p=" before the value?
function label_pvalue(;precision=2, kwargs...)
    bottom = round(10.0^(-precision); digits=precision)
    top = 1-bottom
    function labeler(value::Real)
        if value > top
            lnum = label_number(;prefix=">", kwargs...)
            return lnum(top)
        elseif value < bottom
            lnum = label_number(;prefix="<", kwargs...)
            return lnum(bottom)
        else
            lnum = label_number(;kwargs...)
            return lnum(value)
        end
    end
    return (values) -> labeler.(values)
end

function label_scientific(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(; conversion="e", kwargs...)
        return lnum(value)
    end
    return (values) -> labeler.(values)
end

function label_wrap(width)
    function labeler(value::String)
        words = split(value, ' ')
        wlen = length(words)
        label = ""
        count = 0
        for (i,w) in enumerate(words)
            label *= w
            count += length(w)
            if i != wlen
                if (count+1) >= width
                    label *= "\n"
                    count = 0
                else
                    label *= " "
                    count += 1
                end
            end
        end
        return label
    end
    return (values) -> labeler.(values)
end
