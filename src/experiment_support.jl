using Pandas

"""
Append table or row to CSV file.

julia> using lario3d
julia> lario3d.add_to_csv("file.csv", (:first=>[4, 5], :second=>["a", "b"]))
"""
function add_to_csv(df::Tuple, data_file::AbstractString)
    println(typeof(df))
    println(df)
    dfo = Dict(df)

    println(typeof(dfo))
    # println("adfa: ", dfo[])
    add_to_csv(dfo, data_file)
end

function add_to_csv(df::Dict, data_file::AbstractString)
    # wrap values into array
    println("dict  ")

    new_dict = Dict()
    for (key, val) in df


        println("key ", key, ", val:", df[key])
        new_dict[key] = val

        if !isa(df[key], Array)
            new_dict[key] = [val]
        end
    end


    println("df: ", new_dict)
    dfo = Pandas.DataFrame(new_dict)
    add_to_csv(dfo, data_file)

end

function add_to_csv(df::Pandas.DataFrame, data_file::AbstractString)

    if isfile(data_file)
        df0 = read_csv(data_file)
        df = concat((df0, df); ignore_index=true, sort=false)
    end
    to_csv(df, data_file; index=false)
end
