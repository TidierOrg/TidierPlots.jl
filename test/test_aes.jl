function Base.:(==)(aes1::TidierPlots.Aesthetics, aes2::TidierPlots.Aesthetics)
    if length(aes1.positional) != 0 || length(aes2.positional) != 0
        if length(aes2.positional) != length(aes1.positional)
            return false
        end
        if any(aes1.positional .!= aes2.positional)
            return false
        end
    end

    if length(aes1.named) != 0 || length(aes2.named) != 0
        if length(aes2.named) != length(aes1.named)
            return false
        end
        if length(intersect(keys(aes1.named), keys(aes2.named))) != length(aes1.named)
            return false
        end
        for (k, v) in aes1.named
            if aes2.named[k] != v
                return false
            end
        end
    end

    return true
end

@testset "aes-equal" begin
    @test aes(x = "x", y = "y") == @aes(x = x, y = y)
    @test aes(x = "x", y = "y") == @es(x = x, y = y)
    @test aes(x = "x", y = "y") == aes(x = :x, y = :y)
    @test aes("x", "y") == @aes(x, y)
    @test aes("x", "y") == @es(x, y)
    @test aes("x", "y") == aes(:x, :y)
    @test aes("x", y = "y") == aes(:x, y = :y)
    @test aes("x", y = "y") == @es(x, y = y)
    @test aes("x", y = "y") == @aes(x, y = y)
end

@testset "aes-invalid" begin
    @test_throws ErrorException @macroexpand @aes(x/10)
    to_cm(x) = x ./ 10
    @test_throws ErrorException aes(:x => to_cm)
end
