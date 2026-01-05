@testitem "docs will render" begin
    using Markdown
    using PalmerPenguins
    
    for (path, dirs, files) in walkdir("../docs/examples")  
        for file in files
            if endswith(file, ".jl")
                include(joinpath(path, file))
            end
        end
    end
    @test true
end