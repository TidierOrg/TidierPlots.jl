@testset "label functions" verbose = true begin
@testset "label_number" begin
    lf = label_number()
    @test lf(.1) == "0.1"
    @test lf(.95) == "0.95"
    @test lf(.195) == "0.2"
    @test lf(101) == "101"
    @test lf(-101) == "-101"
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

@testset "label_bytes" begin
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

@testset "label_currency" begin
    lf = label_currency()
    @test lf(1) == "\$1"
    @test lf(1.12) == "\$1.12"
    @test lf(1.128) == "\$1.13"
    @test lf(1128.128) == "\$1,128.13"
end

@testset "label_date" begin
    lf = label_date()
    @test lf(Date("10-12-67", DateFormat("d-m-y"))) == "12/10/67"
    @test lf(Date("10-1-67", DateFormat("d-m-y"))) == "1/10/67"
    @test lf(Date("10-1-67", DateFormat("m-d-y"))) == "10/1/67"
    @test lf(Date("1-1-1967", DateFormat("m-d-y"))) == "1/1/1967"
    @test lf(Date("1-1-1967:4:51:10.150", DateFormat("m-d-y:H:M:S.s"))) == "1/1/1967"
    lf = label_date(;format="d-m-Y:H:M:S")
    @test lf(DateTime("1-1-1967:4:51:10.150", DateFormat("m-d-y:H:M:S.s"))) == "1-1-1967:4:51:10"
end

@testset "label_log" begin
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

@testset "label_percent" begin
    lf = label_percent()
    @test lf(.1) == "10%"
    @test lf(.95) == "95%"
    @test lf(.95112) == "95.11%"
    @test lf(10.95112) == "1,095.11%"
end

@testset "label_ordinal" begin
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

@testset "label_pvalue" begin
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

@testset "label_scientific" begin
    lf = label_scientific()
    @test lf(1) == "1e+00"
    @test lf(1154) == "1.15e+03"
end

@testset "label_wrap" begin
    t1 = "this is a long label"
    t2 = "this is another long label"
    t3 = "this a label this is even longer"
    lf = label_wrap(10)
    lf(t1) == "this is a\nlong label"
    lf(t2) == "this is\nanother\nlong label"
    lf(t3) == "this a\nlabel this\nis even\nlonger"
    lf = label_wrap(20)
    lf(t1) == "this is a long label"
    lf(t2) == "this is another long\nlabel"
    lf(t3) == "this a label this is\neven longer"
    lf = label_wrap(2)
    lf(t1) == "this\nis\na\nlong\nlabel"
end

@testset "scale_x/y_continuous" begin
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
end