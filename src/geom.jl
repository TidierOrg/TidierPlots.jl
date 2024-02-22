function build_geom(aes_dict, args_dict, required_aes, spec_api_function; special_aes = nothing)
    
    if haskey(args_dict, "data")
        # if the code is running in a Pluto.jl notebook
        if args_dict["data"] isa DataFrame
            plot_data = args_dict["data"]
        elseif args_dict["data"] isa Symbol
            plot_data = Base.eval(Main, args_dict["data"])
        elseif args_dict["data"] isa AbstractString
            plot_data = Base.eval(Main, Symbol(args_dict["data"]))
        else
            type = typeof(args_dict["data"])
            @error "Data was provided in an unsupported type: $type"
        end
    else
        plot_data = DataFrame()
    end

    # translation dict to convert ggplot aes terms to Makie terms

    optional_aes = Dict("color" => "color",
                        "colour" => "color",
                        "shape" => "marker",
                        "size" => "markersize",
                        "stroke" => "strokewidth",
                        "strokecolor" => "strokecolor",
                        "strokecolour" => "strokecolor",
                        "linetype" => "linestyle",
                        "linewidth" => "linewidth",
                        "glow" => "glowwidth",
                        "glowcolor" => "glowcolor",
                        "glowcolour" => "glowcolor",
                        "alpha" => "alpha",
                        "stack" => "stack",
                        "dodge" => "dodge",
                        "errorbar_direction" => "direction",
                        "text" => "text",
                        "label" => "text",
                        "row" => "row",
                        "col" => "col", 
                        "layout" => "layout", 
                        "direction" => "direction", 
                        "group" => "group")

    if !isnothing(special_aes)
        optional_aes = merge(optional_aes, special_aes)
    end

    # turn the visual function into a layer with the right args

    #optional_visual_args = optional_aes

    #args_given = intersect(
    #    keys(optional_visual_args),
    #    keys(args_dict)
    #)

    #if isnothing(spec_api_function)
    #    @error("Missing Makie function to plot data.")
    #elseif length(args_given) != 0
        #if there are keyword args, call the spec api function with args and kwargs
        #visual_args = Tuple([plot_data[!, aes_dict[aes]] for aes in required_aes])
    #    visual_kwargs = Dict(Symbol(optional_visual_args[a]) => args_dict[a] for a in args_given)
    #    geom_visual = function(args...)
    #        spec_api_function(args; visual_kwargs...)
    #    end
    #else
        #if not, just call it with the required aes only
        #visual_args = Tuple([plot_data[!, aes_dict[aes]] for aes in required_aes])
    #    geom_visual = spec_api_function
    #end  

    # return a geom object
    return Geom(aes_dict, args_dict,
        plot_data, spec_api_function,
        required_aes, optional_aes, Dict())

end