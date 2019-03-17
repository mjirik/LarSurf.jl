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


