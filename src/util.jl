function TidierPlots_set(option::AbstractString, value::Bool)
    if option == "autoplot"
       autoplot[] = value
    else
      throw("That is not a valid option.")
    end
end

function c(args...)
    return [v for v in args]
end

function layer_equal(L1::Layer, L2::Layer)
    
    if hasfield(typeof(L1.transformation), :plottype) && hasfield(typeof(L2.transformation), :plottype)
        if L1.transformation.plottype != L2.transformation.plottype
            return false
        end

        if L1.transformation.attributes != L2.transformation.attributes
            return false       
        end
    else
        if L1.transformation != L2.transformation
            return false
        end
    end

    if L1.data != L2.data
        return false
    end

    if L1.named != L2.named
        return false
    end

    if L1.positional != L2.positional
        return false
    end

    return true
end

function check_aes(required_aes, aes_dict, geom_name)
    missing_aes = [aes for aes in required_aes if !haskey(aes_dict, aes)]

    if (length(missing_aes) != 0)
        error("$geom_name is missing required aesthetic(s): $missing_aes")
    end
end