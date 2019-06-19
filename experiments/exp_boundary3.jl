
using Revise
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Profile
using TimerOutputs
using ExSu

fn = "exp_boundary3.csv"

# compile
sz1 = 10
b3_size = [sz1,sz1,sz1]
LarSurf.set_param(boundary_allow_write_files=true)
LarSurf.set_param(boundary_allow_read_files=true)
LarSurf.set_param(boundary_allow_memory=true)
LarSurf.get_boundary3(b3_size)
println("======")

function save_stats(acquisition, b3_size, t1)
    dt = Dict()
    dt["time"] = t1
    dt["datetime"] = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    dt["jlfile"] = @__FILE__
    dt["allow_read_files"] = LarSurf._param_boundary_allow_read_files
    dt["allow_write_files"] = LarSurf._param_boundary_allow_write_files
    dt["allow_memory"] = LarSurf._param_boundary_allow_memory
    dt["block_size"] = b3_size[1]
    dt["acquisition"] = acquisition
    # println(dt)
    println(t1)
    ExSu.add_to_csv(dt, fn)
end

function run_all(b3_size)
    # LarSurf.set_param(boundary_allow_files=false)
    fn = LarSurf._create_name_for_boundary(b3_size)
    if isfile(fn)
        print("D")
        rm(fn)
    end
    LarSurf.set_param(boundary_allow_read_files=false)
    LarSurf.set_param(boundary_allow_write_files=true)
    LarSurf.set_param(boundary_allow_memory=false)
    t1 = @elapsed LarSurf.get_boundary3(b3_size)
    save_stats("write", b3_size, t1)

    # LarSurf.set_param(boundary_allow_files=true)
    LarSurf.set_param(boundary_allow_read_files=true)
    LarSurf.set_param(boundary_allow_write_files=false)
    LarSurf.set_param(boundary_allow_memory=false)
    t1 = @elapsed LarSurf.get_boundary3(b3_size)
    save_stats("read", b3_size, t1)

    LarSurf.set_param(boundary_allow_read_files=false)
    LarSurf.set_param(boundary_allow_write_files=false)
    LarSurf.set_param(boundary_allow_memory=false)
    t1 = @elapsed LarSurf.get_boundary3(b3_size)
    save_stats("computation", b3_size, t1)


    # LarSurf.set_param(boundary_allow_files=true)
    LarSurf.set_param(boundary_allow_read_files=false)
    LarSurf.set_param(boundary_allow_write_files=false)
    LarSurf.set_param(boundary_allow_memory=true)
    t1 = @elapsed LarSurf.get_boundary3(b3_size)
    save_stats("memory", b3_size, t1)

end

    # to have 3 samples per each size
for i=1:3
    for sz1=5:5:30
        b3_size = [sz1, sz1, sz1]
        run_all(b3_size)
    end
end
