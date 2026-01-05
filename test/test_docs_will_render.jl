@testitem "docs will render" begin
    using Markdown
    
    for (path, dirs, files) in walkdir("../docs/examples")  
        for file in files
            if endswith(file, ".jl")
                include(joinpath(path, file))
                @test true
            end
        end
    end
end