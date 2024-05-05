function subgroup_split(given_aes, grouping_columns)
    grouping_columns.index = 1:nrow(grouping_columns)
    group_index_list = [df.index for df in groupby(grouping_columns, Not(:index))]
    return [subset_aes(given_aes, index) for index in group_index_list]
end

function subset_aes(given_aes, index)
    subset_given_aes_dict = Dict{Symbol, PlottableData}()
    for (key, value) in given_aes
        subset_given_aes_item = PlottableData(
            value.raw[index, :],
            value.makie_function,
            value.label_target,
            value.label_function
        )
        push!(subset_given_aes_dict, key => subset_given_aes_item)
    end
    return subset_given_aes_dict
end