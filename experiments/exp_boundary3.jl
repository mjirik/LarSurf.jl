
using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Profile
using TimerOutputs

fn = "exp_boundary3.csv"

# compile
sz1 = 10
b3_size = [sz1,sz1,sz1]
lario3d.set_param(boundary_allow_write_files=true)
lario3d.set_param(boundary_allow_read_files=true)
lario3d.set_param(boundary_allow_memory=true)
lario3d.get_boundary3(b3_size)
println("======")

function save_stats(acquisition, b3_size, t1)
    dt = Dict()
    dt["time"] = t1
    dt["datetime"] = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    dt["jlfile"] = @__FILE__
    dt["allow_read_files"] = lario3d._param_boundary_allow_read_files
    dt["allow_write_files"] = lario3d._param_boundary_allow_write_files
    dt["allow_memory"] = lario3d._param_boundary_allow_memory
    dt["block_size"] = b3_size[1]
    dt["acquisition"] = acquisition
    # println(dt)
    println(t1)
    lario3d.add_to_csv(dt, fn)
end

function run_all(b3_size)
    # lario3d.set_param(boundary_allow_files=false)
    fn = lario3d._create_name_for_boundary(b3_size)
    if isfile(fn)
        print("D")
        rm(fn)
    end
    lario3d.set_param(boundary_allow_read_files=false)
    lario3d.set_param(boundary_allow_write_files=true)
    lario3d.set_param(boundary_allow_memory=false)
    t1 = @elapsed lario3d.get_boundary3(b3_size)
    save_stats("write", b3_size, t1)

    # lario3d.set_param(boundary_allow_files=true)
    lario3d.set_param(boundary_allow_read_files=true)
    lario3d.set_param(boundary_allow_write_files=false)
    lario3d.set_param(boundary_allow_memory=false)
    t1 = @elapsed lario3d.get_boundary3(b3_size)
    save_stats("read", b3_size, t1)

    lario3d.set_param(boundary_allow_read_files=false)
    lario3d.set_param(boundary_allow_write_files=false)
    lario3d.set_param(boundary_allow_memory=false)
    t1 = @elapsed lario3d.get_boundary3(b3_size)
    save_stats("computation", b3_size, t1)


    # lario3d.set_param(boundary_allow_files=true)
    lario3d.set_param(boundary_allow_read_files=false)
    lario3d.set_param(boundary_allow_write_files=false)
    lario3d.set_param(boundary_allow_memory=true)
    t1 = @elapsed lario3d.get_boundary3(b3_size)
    save_stats("memory", b3_size, t1)

end

    # to have 3 samples per each size
for i=1:3
    for sz1=5:5:30
        b3_size = [sz1, sz1, sz1]
        run_all(b3_size)
    end
end
