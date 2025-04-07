# metaloops-25

This repository aims to facilitate the conversion of Hi-C data formats h5, bedpe and cool into mcool, which can be used to run metaloops for loop calling. These conversion scripts are located in [Conversion_scripts](https://github.com/ccarloscr/metaloops-25/blob/main/Conversion_scripts).


## Installation

To install the pipeline clone the repository:
```bash
git clone https://github.com/ccarloscr/metaloops-25
cd metaloops-25
```

The conversion scripts require python3, hdf5plugin, h5py, numpy, cooler.

Metaloops require cooler, R (v4), optparse, data.table, igraph, mlack, EBImage and rhdf5.





## Configuration

The scripts on this reposition are configured to run using SLURM. Change the scripts' headers according to your preferred job manager.



- Get bedpe files
- Convert to cool files
- Merge relicates
- Convert to mcool
- Run metaloops




## Credits
This project uses the script [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R) developed by Julien Dorier and the Lausanne University, available under license [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). The original repository can be found in [[meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main)].
