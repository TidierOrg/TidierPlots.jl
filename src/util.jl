function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "autoplot"
       autoplot[] = value
    elseif option == "plot_log"
        plot_log[] = value
    elseif option == "plot_show"
        plot_show[] = value
    else
      throw("That is not a valid option.")
    end
end

function c(args...)
    @warn "The julia equivalent of 'c(1, 2, 3)' in R is `[1, 2, 3]`." maxlog=2
    return reduce(vcat, args)
end

function check_aes(required_aes, aes_dict, geom_name)
    missing_aes = [aes for aes in required_aes if !haskey(aes_dict, aes)]

    if (length(missing_aes) != 0)
        error("$geom_name is missing required aesthetic(s): $missing_aes")
    end
end

function do_nothing(aes_dict, args_dict, required_aes, plot_data)
    return (aes_dict, args_dict, required_aes, plot_data)
end
