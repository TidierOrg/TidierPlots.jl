@testset "test conversions" verbose = true begin
    int_array = [1, 2, 3]
    num_array = [1.0, 2.0, 3.0]
    cat_array = CategoricalArray(int_array)
    color_array = TidierPlots._default_discrete_palette.(int_array)
    color_array_c = TidierPlots._default_continuous_palette.(num_array)

    @test TidierPlots.try_convert(Symbol, "test", "dodge", "geom_bar") == :test
    @test_throws ArgumentError TidierPlots.try_convert(Integer, "test", "dodge", "geom_bar")

    @testset "to integer" begin
        @test all(
            TidierPlots.convert_aes_type(num_array, Integer, :dodge) .== int_array
        )
        @test all(
            TidierPlots.convert_aes_type(int_array, Integer, :dodge) .== int_array
        )
        @test all(
            TidierPlots.convert_aes_type(cat_array, Integer, :dodge) .== int_array
        )
    end

    #@testset "to colorant" begin
    #@test all(
    #    TidierPlots.convert_aes_type(num_array, Colorant, :color) .== #color_array
    #)
    #@test all(
    #    TidierPlots.convert_aes_type(int_array, Colorant, :color) .== #color_array
    #)
    #@test all(
    #    TidierPlots.convert_aes_type(cat_array, Colors.Colorant, :color) .== #color_array_c
    #)
    #end
end
