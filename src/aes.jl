function aes(;kwargs...)
    d = Dict(kwargs)
    return Aesthetics(Dict([String(key) => d[key] for key in keys(d)]))
end