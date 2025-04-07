# metaloops-25

This repository aims to facilitate the conversion of Hi-C data formats h5, bedpe and cool into mcool, which can be used to run metaloops for loop calling. These conversion scripts are located in [Conversion_scripts](https://github.com/ccarloscr/metaloops-25/blob/main/Conversion_scripts).


## Installation

To install the pipeline clone the repository:
```bash
git clone https://github.com/ccarloscr/metaloops-25
cd metaloops-25
```

Metaloops and conversion scripts require python3, hdf5plugin, h5py, numpy, cooler and R (v4). These programs are detailed in the environment.yml file provided. The required R packages are installed when run_metaloops.sh is ran.

Create a conda environment named workplace using the provided environment.yml:
```bash
conda env create --name workplace --file=environment.yml
```

## Configuration

The scripts on this reposition are configured to run using SLURM. Change the scripts' headers according to your preferred job manager.


## Credits
This project uses the script [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R) developed by Julien Dorier and the Lausanne University, available under license [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). The original repository can be found in [[meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main)].
