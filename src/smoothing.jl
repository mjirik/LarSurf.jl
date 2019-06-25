module Smoothing

function eye(sz)
    arr = spzeros(Int8, sz, sz)
    for i=1:sz
        arr[i,i] = 1
    end
    return arr
end

function setIzero!(arr)
    for i=1:size(arr)[1]
        arr[i,i] = 0
    end
    return arr
end

function getDiag(arr)
    sz = size(arr)[1]
    arro = zeros(eltype(arr), sz)
    for i=1:sz
        arro[i] = arr[i,i]
    end
    return arro
end

function make_full(arr)
    arrout = Array{eltype(arr), 2}(undef, size(arr)...)
    for i=1:size(arr)[1]
        for j=1:size(arr)[2]
            arrout[i,j] = arr[i,j]
        end
    end
    return arrout
end
#neighboor vertexes

function smoothing(V, EVch, k=0.35)
#     Matrix(setIzero!(EVch' * EVch))

    neighboorNumber = getDiag(EVch' * EVch)
    neighboors = setIzero!(EVch' * EVch)

#     targetV =  neighboors * V' ./ neighboorNumber
#     diff = targetV - V'
#     newV = (V' + k * diff)'

    targetV = V * neighboors ./ neighboorNumber'
    # println("targetV shape: ", size(targetV))
    diff = targetV - V
    # println("diff shape: ", size(diff))
    newV = V + k * diff

    return make_full(newV)
end

end
