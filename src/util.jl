function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "plot_pluto"
        plot_pluto[] = value
    elseif option == "plot_log"
        plot_log[] = value
    elseif option == "plot_show"
        plot_show[] = value
    elseif option == "verbose"
        verbose[] = value
    else
        throw(ArgumentError("That is not a valid option."))
    end
end

function c(args...)
    return reduce(vcat, args)
end

function do_nothing(aes_dict, args_dict, required_aes, plot_data)
    return (aes_dict, args_dict, required_aes, plot_data)
end

function accepted_options_by_type(type::Symbol)
    lowercase_type = Symbol(lowercase(string(type)))
    return Makie.attribute_names(Plot{getfield(Makie, lowercase_type)})
end
