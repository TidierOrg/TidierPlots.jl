function make_aes_extractor(required_aes)
    return function extract_aes(args, kwargs)
        aes_dict = Dict{Symbol,Pair}()
        args_dict = Dict{String,Any}()

        for arg in args
            if arg isa DataFrame
                args_dict["data"] = arg
            elseif arg isa Aesthetics
                if length(arg.positional) != 0
                    if length(required_aes) == 0
                        throw(ArgumentError("Positional aes detected, but meaning is ambiguous. Please use aes names in your aes call (e.g. @aes(x = x) instead of @aes(x))."))
                    end

                    for (i, pos_arg) in enumerate(arg.positional)
                        if haskey(arg.named, Symbol(required_aes[i][1]))
                            bad_aes = required_aes[i][1]
                            throw(ArgumentError("Required aes ($bad_aes) given both positionally and by name. Choose one or the other."))
                        end
                        push!(aes_dict, Symbol(required_aes[i]) => pos_arg)
                    end
                end
                merge!(aes_dict, arg.named)
            end
        end

        d = Dict(kwargs)
        args_dict = merge(args_dict,
            Dict([String(key) => d[key] for key in keys(d)]))

        return (aes_dict, args_dict)
    end
end

extract_aes = make_aes_extractor([])

@testitem "extract aes" begin
    @test_throws ArgumentError TidierPlots.extract_aes([aes(:x)], Dict())

    x_extractor = TidierPlots.make_aes_extractor(["x"])

    @test_throws ArgumentError x_extractor([aes(:col1, x = :col2)], Dict())

    pos = x_extractor([aes(:col1)], Dict())
    named = x_extractor([aes(x = :col1)], Dict())

    @test pos[1][:x] == named[1][:x]
end