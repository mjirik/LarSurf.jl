include("../src/lario3d.jl")

block_size = [5, 5, 5]
margin_size = 0

## Artifical data
data3d = zeros(Int16,15,14,30)
data3d[2:4,2:3,2] .= 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0

blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
    size(data3d), block_size)
print(size(data3d))
print("\n")
print(blocks_number, blocks_number_axis)

block0 = lario3d.get_block(data3d, block_size, margin_size, blocks_number_axis, 0)



# lario3d.prepare_for_block_processing()
