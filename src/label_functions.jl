"""
    label_bytes(;units=:si, kwargs...)

Convert numeric values into human-readable strings representing byte sizes.

# Arguments
- `units`: Can be `:si` for SI units (powers of 10), `:binary` for binary units (powers of 1024), or a specific unit string (e.g., MB, GiB).
- `kwargs...`: Additional keyword arguments passed to `label_number`.

# Examples
```julia
labeler = label_bytes(units=:si)
labeler([1024, 2048]) # ["1.02 KB", "2.05 KB"]
```
"""
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

"""
    label_currency(;kwargs...)

Convert numeric values into currency strings.

# Arguments

- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_currency()
labeler([100, 200.75]) # ["\$100", "\$200.75"]
```
"""
function label_currency(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(; prefix="\$", kwargs...)
        return lnum(float(value))
    end
    return (values) -> labeler.(values)
end

"""
    label_date(;format="m/d/Y")

Convert Date or DateTime values into formatted strings.

# Arguments

- `format`: A date format string.

# Examples

```julia
labeler = label_date(format="Y-m-d")
labeler([Date(2020, 1, 1)]) # ["2020-1-1"]
```
"""
function label_date(;format="m/d/Y")
    function labeler(value::T) where T <: TimeType
        Dates.format(value, format)
    end
    return (values) -> labeler.(values)
end

"""
    label_log(;base=10, kwargs...)

Convert numeric values into logarithmic strings with a specified base.

# Arguments

- `base`: The logarithmic base.
- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_log(base=10)
labeler([10, 100]) # ["10^1", "10^2"]
```
"""
function label_log(;base=10, kwargs...)
    function labeler(value::Real)
        exp = log(base, value)
        lnum = label_number(; prefix="$base^", kwargs...)
        return lnum(exp)
    end
    return (values) -> labeler.(values)
end

"""
    label_number(;precision=2, scale=1, prefix="", suffix="", decimal_mark=".", comma_mark=",", style_positive=:none, style_negative=:hyphen, kwargs...)

Format numeric values as strings with various styling options.

# Arguments

- `precision`: Number of decimal places.
- `scale`: Scaling factor applied to the numbers before formatting.
- `prefix`: String to prepend to the number.
- `suffix`: String to append to the number.
- `decimal_mark`: Character to use as the decimal point.
- `comma_mark`: Character to use as the thousands separator.
- `style_positive`: Style for positive numbers (:none, :plus, :space).
- `style_negative`: Style for negative numbers (:hyphen, :parens).
- `kwargs`: Additional keyword arguments passed on to `format` from `Format.jl`

# Examples

```julia
labeler = label_number(precision=0, suffix="kg")
labeler([1500.12, -2000.12]) # ["1,500kg", "-2,000kg"]
```
"""
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

"""
    label_ordinal(;kwargs...)

Convert numeric values into ordinal strings (e.g., 1st, 2nd, 3rd).

# Arguments

- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_ordinal()
labeler([1, 2, 3]) # ["1st", "2nd", "3rd"]
```
"""
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

"""
    label_percent(;kwargs...)

Convert numeric values into percentage strings.

# Arguments

- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_percent()
labeler([0.1, 0.256]) # ["10%", "25.6%"]
```
"""
function label_percent(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(;scale=100, suffix="%", kwargs...)
        return lnum(value)
    end
    return (values) -> labeler.(values)
end

"""
    label_pvalue(;precision=2, kwargs...)

Format p-values, handling very small or large values with special notation.

# Arguments

- `precision`: Number of decimal places for thresholding small values.
- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_pvalue()
labeler([0.0001, 0.05, 0.9999]) # ["<0.01", "0.05", ">0.99"]
```
"""
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

"""
    label_scientific(;kwargs...)

Convert numeric values into scientific notation strings.

# Arguments

- `kwargs`: Additional keyword arguments passed to `label_number`.

# Examples

```julia
labeler = label_scientific()
labeler([1000, 2000000]) # ["1e+03", "2e+06"]
```
"""
function label_scientific(;kwargs...)
    function labeler(value::Real)
        lnum = label_number(; conversion="e", kwargs...)
        return lnum(value)
    end
    return (values) -> labeler.(values)
end

"""
    label_wrap(width)

Wrap text strings to a specified width, breaking at spaces.

# Arguments

- `width`: The maximum number of characters in a line before wrapping.

# Examples

```julia
labeler = label_wrap(10)
labeler(["This is a long sentence."]) # ["This is a\nlong\nsentence."]
```
"""
function label_wrap(width)
    function labeler(value::String)
        words = split(value, ' ')
        label_len = length(words)
        label = ""
        count = 0
        for (i,w) in enumerate(words)
            w_len = length(w)
            if (count+length(w)) >= width
                if i != 1
                    label *= "\n"
                end
                label *= w
                count = w_len
            else
                if i != 1
                    label *= " "
                    count += 1
                end
                label *= w
                count += w_len
            end
        end
        return label
    end
    return (values) -> labeler.(values)
end
