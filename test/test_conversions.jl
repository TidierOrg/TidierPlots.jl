@testset "conversions" verbose = true begin
    int_array = [1, 2, 3]
    num_array = [1.0, 2.0, 3.0]
    cat_array = CategoricalArray(int_array)
    color_array = TidierPlots._default_discrete_palette.(int_array)

    @test TidierPlots.try_convert(Symbol, "test", "dodge", "geom_bar") == :test
    @test_throws ArgumentError TidierPlots.try_convert(Integer, "test", "dodge", "geom_bar")

    @test all(
        TidierPlots.convert_aes_type(num_array, Integer, :dodge) .== int_array
    )
    @test all(
        TidierPlots.convert_aes_type(int_array, Integer, :dodge) .== int_array
    )
    @test all(
        TidierPlots.convert_aes_type(cat_array, Integer, :dodge) .== int_array
    )
    @test all(
        TidierPlots.convert_aes_type(num_array, Colors.Colorant, :color) .==
            [RGB(0.190631, 0.407061, 0.556089),
            RGB(0.20803, 0.718701, 0.472873),
            RGB(0.993248, 0.906157, 0.143936)]
    )
    @test all(
        TidierPlots.convert_aes_type(
            ["a", "b", "c"], Colors.Colorant, :color) .==
            [RGB(0.0, 0.4470588235294118, 0.6980392156862745),
            RGB(0.9019607843137255, 0.6235294117647059, 0.0),
            RGB(0.0, 0.6196078431372549, 0.45098039215686275)]
    )
    @test all(
        TidierPlots.convert_aes_type(
            CategoricalArray(["a", "b", "c"]), Colors.Colorant, :color) .==
            [RGB(0.0, 0.4470588235294118, 0.6980392156862745),
            RGB(0.9019607843137255, 0.6235294117647059, 0.0),
            RGB(0.0, 0.6196078431372549, 0.45098039215686275)]
    )
end
