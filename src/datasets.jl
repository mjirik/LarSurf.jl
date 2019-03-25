#=
datasets.jl:
- Julia version: 
- Author: Jirik
- Date: 2019-03-03
=#


function random_image(shape, obj_min, obj_max, level)
    print("Random image start")
    im = rand(shape...)

    for i in obj_min[1]:obj_max[1]
        for j in obj_min[2]:obj_max[2]
            im[i,j] = im[i,j] + level
        end
    end
    return im
end


function generate_slope(data_size)
    data = zeros(Int8, data_size[1], data_size[2], data_size[3])
    for i=1:data_size[1]
        for j=1:data_size[2]
            for k=1:data_size[3]
                if ((j - k) < i) & ((j - k + 3) >= i)
                    data[i,j,k] = 1
                end
#                 if i > (j - k)
#                 if (k - j) < i
#                     data[i,j,k] = 1
#                 end
            end
        end
    end
    return data
end