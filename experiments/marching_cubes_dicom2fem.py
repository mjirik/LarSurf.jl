import io3d
from dicom2fem.seg2fem import gen_mesh_from_voxels_mc, smooth_mesh
import time
import pandas as pd
from pathlib import Path
import datetime
import platform
table_fn = "exp_surface_extraction5_test2.csv"
# table_fn = ""

fn = "exp_surface_extraction5_test.csv"
class Report(object):
    """docstring for Report."""

    def __init__(self, fn):
        super(Report, self).__init__()
        self.fn = Path(fn)
        self.actual_row = {}
        self.df = None

    def add_cols_to_actual_row(self, data):
        self.actual_row.update(data)

    # def write_table(self, filename):
    def finish_actual_row(self):
        data = self.actual_row
        # data.update(self.persistent_cols)
        if self.fn.exists():
            print("file exist reading")
            self.df = pd.read_csv(self.fn)

        else:
            print("empty file")
            self.df = pd.DataFrame()
        df = pd.DataFrame([list(data.values())], columns=list(data.keys()))
        self.df = self.df.append(df, ignore_index=True, sort=False)
        self.actual_row = {}
        # import ipdb; ipdb.set_trace()
        self.df.to_csv(self.fn, index=False)

report = Report(table_fn)

for id in range(1, 21):

    fn = io3d.datasets.join_path("medical", "orig", "3Dircadb1.{}".format(id), "MASKS_DICOM", "liver", get_root=True)
    datap = io3d.read(fn)

    data3d = datap["data3d"]
    voxelsize_mm = datap["voxelsize_mm"]
    seg = data3d > 0

    # seg = seg[::2,::4,::4]
    print(seg.shape)

    t0 = time.time()
    gen_mesh_from_voxels_mc(seg, voxelsize_mm)
    t1 = time.time()

    print("Time: ", t1-t0)
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    dct = {
    "experiment": "Ircadb1",
    "data parameter": id,
    "datetime": timestamp,
    "fcn": "marching cubes",
    "elapsed" : t1-t0,
    "hostname": platform.node(),
    "jlfile": __FILE__
    }
    # print(dct)
    report.add_cols_to_actual_row(dct)
    report.finish_actual_row()
