using Pandas
using Dates

"""
Append table or row to CSV file.

julia> using lario3d
julia> lario3d.add_to_csv("file.csv", (:first=>[4, 5], :second=>["a", "b"]))
"""
function add_to_csv(df::Tuple, data_file::AbstractString)
    dfo = Dict(df)
    add_to_csv(dfo, data_file)
end

function add_to_csv(df::Dict, data_file::AbstractString)
    # wrap values into array
    wrap_with_array = false
    for (key, val) in df
        if !isa(val, Array)
            wrap_with_array = true
            break
        end
    end

    new_dict = Dict()
    for (key, val) in df
        if wrap_with_array
            new_dict[key] = [val]
        else
            new_dict[key] = val
        end
    end


    dfo = Pandas.DataFrame(new_dict)
    add_to_csv(dfo, data_file)

end

function add_to_csv(df::Pandas.DataFrame, data_file::AbstractString)

    if isfile(data_file)
        df0 = read_csv(data_file)
        df = concat((df0, df); ignore_index=true, sort=false)
    end
    to_csv(df, data_file; index=false) #, sep=";")
end


"""
Add description of segmentation to dictionary
"""
function segmentation_description_to_dict!(dct, segmentation, data_name="data_")
    n_zeros = sum(segmentation.==0)
    n_non_zeros = sum(segmentation.!=0)
    dct[data_name * "size_1"] = size(segmentation)[1]
    dct[data_name * "size_2"] = size(segmentation)[2]
    dct[data_name * "size_3"] = size(segmentation)[3]
    dct[data_name * "zeros_number"] = n_zeros
    dct[data_name * "non_zeros_number"] = n_non_zeros
    dct[data_name * "voxel_number"] = prod(size(segmentation))
    return dct
end

"""
experiment is string used to tag experiment
"""
function timed_to_dict!(dct, timed; experiment=nothing, datetime=true)
    dct["elapsed"] = timed[2]
    dct["alocated"] = timed[3]
    if experiment != nothing
        dct["experiment"] = experiment
    end
    if datetime
        dct["datetime"] = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    end
    return dct
end

function size_to_dict!(dct, data_size, data_name="")
    dct[data_name * "size_1"] = data_size[1]
    dct[data_name * "size_2"] = data_size[2]
    dct[data_name * "size_3"] = data_size[3]
    return dct
end
