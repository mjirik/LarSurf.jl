using Pandas

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
