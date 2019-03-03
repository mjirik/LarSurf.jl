using PyCall


function read3d(fn)
    pyio3d = pyimport("io3d")

    return pyio3d["read"](fn)
end

function datasets_join_path(pth)
    pyio3d_datasets = pyimport("io3d.datasets")
    print(pth)
    opth = pyio3d_datasets["join_path"](pth, get_root=true)
    print(opth)
    return opth
end


function random_image(shape, obj_min, obj_max, level)
    im = rand(shape...)

    for i in obj_min[1]:obj_max[1]
        for j in obj_min[2]:obj_max[2]
            im[i,j] = im[i,j] + level
        end
    end
    return im
end