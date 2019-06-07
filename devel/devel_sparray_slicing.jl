using SparseArrays

arr1 = spzeros(Int64, 5, 5)
arr2 = spzeros(Int64, 5, 1)

arr2[4] = 1
arr1[3,:] = arr2[:,1]
arr2[4] = 2

# display(arr1)
display(Matrix(arr1))
