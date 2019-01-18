
function print_slice3(xst, xsp, yst, ysp, zst, zsp)
    print("[", xst, ":", xsp, ", ", yst, ":", ysp, ", ", zst, ":", zsp, "]")
end

function print_array_stats(data3d)
    print(
        "size: ", size(data3d),", type: ", eltype(data3d),
        ", min, max: ", minimum(data3d), ", ", maximum(data3d), "\n"
    )
end
