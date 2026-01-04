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

@testitem "label_number" begin
    lf = label_number()
    @test lf(.1) == "0.1"
    @test lf(.95) == "0.95"
    @test lf(.195) == "0.2"
    @test lf(101) == "101"
    @test lf(-101) == "-101"
    @test_throws ErrorException lf = label_number(style_positive = :error)
    @test_throws ErrorException lf = label_number(style_negative = :error)
    lf = label_number(;precision=1)
    @test lf(.1) == "0.1"
    @test lf(.95) == "0.9"
    @test lf(.195) == "0.2"
    @test lf(101) == "101"
    lf = label_number(;scale=10)
    @test lf(.1) == "1"
    @test lf(.95) == "9.5"
    @test lf(.195) == "1.95"
    @test lf(101) == "1,010"
    lf = label_number(;prefix="->")
    @test lf(.1) == "->0.1"
    lf = label_number(;suffix="%")
    @test lf(.1) == "0.1%"
    lf = label_number(;decimal_mark=",")
    @test lf(.1) == "0,1"
    lf = label_number(;comma_mark="_", decimal_mark=",")
    @test lf(1000.1) == "1_000,1"
    lf = label_number(;style_positive=:plus)
    @test lf(1000.1) == "+1,000.1"
    lf = label_number(;style_positive=:space)
    @test lf(1000.1) == " 1,000.1"
    lf = label_number(;style_negative=:parens)
    @test lf(-1000.1) == "(1,000.1)"
    lf = label_number(;prefix="->", style_negative=:parens)
    @test lf(-1000.1) == "->(1,000.1)"
    lf = label_number(;suffix="mg", style_negative=:parens)
    @test lf(-1000.1) == "(1,000.1)mg"
end

@testitem "label_bytes" begin
    lf = label_bytes()
    @test lf(1) == "1 B"
    @test lf(1e3) == "1 KB"
    @test lf(1.54 * 1e14) == "154 TB"
    lf = label_bytes(;units=:binary)
    @test lf(1) == "1 B"
    @test lf(1024) == "1 KiB"
    @test lf(1024.0^7) == "1 ZiB"
    lf = label_bytes(;units=:GB)
    @test lf(1) == "0 GB"
    @test lf(1e9) == "1 GB"
    @test lf(1000 * 1e9) == "1,000 GB"
end

@testitem "label_currency" begin
    lf = label_currency()
    @test lf(1) == "\$1"
    @test lf(1.12) == "\$1.12"
    @test lf(1.128) == "\$1.13"
    @test lf(1128.128) == "\$1,128.13"
end

@testitem "label_date" begin
    using Dates
    lf = label_date()
    @test lf(Date("10-12-67", DateFormat("d-m-y"))) == "12/10/67"
    @test lf(Date("10-1-67", DateFormat("d-m-y"))) == "1/10/67"
    @test lf(Date("10-1-67", DateFormat("m-d-y"))) == "10/1/67"
    @test lf(Date("1-1-1967", DateFormat("m-d-y"))) == "1/1/1967"
    @test lf(Date("1-1-1967:4:51:10.150", DateFormat("m-d-y:H:M:S.s"))) == "1/1/1967"
    lf = label_date(;format="d-m-Y:H:M:S")
    @test lf(DateTime("1-1-1967:4:51:10.150", DateFormat("m-d-y:H:M:S.s"))) == "1-1-1967:4:51:10"
end

@testitem "label_log" begin
    lf = label_log()
    @test lf(10) == "10^1"
    @test lf(0) == "10^-Inf"
    @test lf(1) == "10^0"
    @test lf(12) == "10^1.08"
    @test lf(35) == "10^1.54"
    @test lf(900) == "10^2.95"
    @test lf(90000000000) == "10^10.95"
    lf = label_log(;base=2)
    @test lf(100) == "2^6.64"
    @test lf(2) == "2^1"
    @test lf(4) == "2^2"
    @test lf(4.4) == "2^2.14"
    @test lf(16.4) == "2^4.04"
end

@testitem "label_percent" begin
    lf = label_percent()
    @test lf(.1) == "10%"
    @test lf(.95) == "95%"
    @test lf(.95112) == "95.11%"
    @test lf(10.95112) == "1,095.11%"
end

@testitem "label_ordinal" begin
    lf = label_ordinal()
    @test lf(100) == "100th"
    @test lf(20) == "20th"
    @test lf(21) == "21st"
    @test lf(100_023) == "100,023rd"
    @test lf(1) == "1st"
    @test lf(2) == "2nd"
    @test lf(0) == "0th"
    @test lf(3) == "3rd"
end

@testitem "label_pvalue" begin
    lf = label_pvalue()
    @test lf(-.1) == "<0.01"
    @test lf(0) == "<0.01"
    @test lf(.01) == "0.01"
    @test lf(.5) == "0.5"
    @test lf(.975) == "0.97"
    @test lf(.99) == "0.99"
    @test lf(.999) == ">0.99"
    @test lf(999) == ">0.99"
end

@testitem "label_scientific" begin
    lf = label_scientific()
    @test lf(1) == "1e+00"
    @test lf(1154) == "1.15e+03"
end

@testitem "label_wrap" begin
    t1 = "this is a long label"
    t2 = "this is another long label"
    t3 = "this a label this is even longer"
    lf = label_wrap(10)
    @test lf(t1) == "this is a\nlong label"
    @test lf(t2) == "this is\nanother\nlong label"
    @test lf(t3) == "this a\nlabel this\nis even\nlonger"
    lf = label_wrap(20)
    @test lf(t1) == "this is a long label"
    @test lf(t2) == "this is another long\nlabel"
    @test lf(t3) == "this a label this is\neven longer"
    lf = label_wrap(2)
    @test lf(t1) == "this\nis\na\nlong\nlabel"
end

@testitem "scale_x/y_continuous" setup = [TidierPlotsSetup] begin
    t = ggplot(penguins) +
        geom_point(aes(x = :bill_depth_mm, y = :body_mass_g)) +
        scale_y_continuous(labels=label_currency()) +
        scale_x_continuous(labels=label_percent(;scale=1))

    m = Makie.plot(
            Makie.SpecApi.GridLayout(
                Makie.SpecApi.Axis(
                    plots = [
                        Makie.PlotSpec(
                            :Scatter,
                            penguins.bill_depth_mm,
                            penguins.body_mass_g;
                        )
                    ],
                    ytickformat = label_currency(),
                    xtickformat = label_percent(;scale=1)
                )
            )
        )

   @test plot_images_equal(t, m)
end

