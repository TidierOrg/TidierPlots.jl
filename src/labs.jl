macro labs(exprs...)
    # there should only be args 
    aes_dict, args_dict = extract_aes(:($(exprs)))

    return labs(args_dict)
end