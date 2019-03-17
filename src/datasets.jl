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
