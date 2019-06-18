using JLD2, FileIO

data = zeros(Int8, 2, 2)
data[2,2] =1

save("file.jld2","data", data)
#
uu = load("file.jld2", "data")
uu
