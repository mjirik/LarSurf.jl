#=
datasets.jl:
- Julia version:
- Author: Jirik
- Date: 2019-03-03
=#


function random_image(shape, obj_min, obj_max, level)
    # print("Random image start")
    im = rand(shape...)

    for i=obj_min[1]:obj_max[1]
        for j=obj_min[2]:obj_max[2]
            for k=obj_min[3]:obj_max[3]
                im[i,j,k] = im[i,j,k] + level
            end
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

function data234()
    @info "data234 init"
    data_size = [2,3,4]
    segmentation = zeros(Int8, 2, 3, 4)
    segmentation[1:2,2:3,3:4] .= 1
    return segmentation
end

function tetris_brick()
    @info "data tetris init"
    segmentation = zeros(Int8, 3, 4, 5)
    segmentation[2,2,2:4] .= 1
    segmentation[2,3,3] = 1
    return segmentation
end
