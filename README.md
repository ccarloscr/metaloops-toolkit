# metaloops-25

Utilities for converting Hi-C contact data into multi-resolution Cooler (`.mcool`) files and running the original `meta_loops.R` meta-loop caller from the Gambetta Lab [meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main) repository.

> **Important:** This repository does **not** implement a new meta-loop calling algorithm.  
> The meta-loop caller included here, `meta_loops.R`, is a copy of the original script from:
> [gambettalab/meta-loops-2022/loop_calling/meta_loops.R](https://github.com/gambettalab/meta-loops-2022/blob/main/loop_calling/meta_loops.R)
>
> The additional code in this repository consists mainly of:
>
> - format-conversion helper scripts,
> - Drosophila/dm6-oriented defaults,
> - SLURM job scripts for running the conversion and meta-loop-calling steps on an HPC cluster.


## Repository structure

```text
metaloops-25/
├── README.md
├── LICENSE
├── NOTICE.md
├── CITATION.cff
├── environment.yml
├── .gitignore
│
├── config/
│   ├── example.env
│   └── dm6.chrom.sizes.txt
│
├── scripts/
│   ├── h52bedpe.py
│   ├── bedpe2cool.sh
│   ├── cool2mcool.sh
│   └── run_metaloops.sh
│
├── slurm/
│   ├── h52bedpe.sbatch
│   ├── bedpe2cool.sbatch
│   ├── cool2mcool.sbatch
│   └── metaloops.sbatch
│
└── third_party/
    └── meta-loops-2022/
        └── meta_loops.R
```


## What this repository does

This repository helps run the following workflow:

| Step | Input | Output | Script |
| :--- | :--- | :--- | :--- |
| 1 | `.h5` Hi-C matrix files | `.bedpe` | `Conversion_scripts/h52bedpe.py` or `run_h52bedpe.sh` |
| 2 | `.bedpe` | `.cool` | `Conversion_scripts/bedpe2cool.sh` |
| 3 | `.cool` | `.mcool` | `Conversion_scripts/cool2mcool.sh` |
| 4 | `.mcool` | meta-loop calls (`.tsv`) | `run_metaloops.sh` + `meta_loops.R` |

The final output of `meta_loops.R` is a tab-separated file with one row per called meta-loop and columns describing both anchors.



## Installation

Clone this repository:
```bash
git clone https://github.com/ccarloscr/metaloops-25
cd metaloops-25
```

Create and activate the conda environment:
```bash
conda env create -f environment.yml
conda activate metaloops
```

The environment includes the main dependencies needed for the conversion scripts and for running the original `meta_loops.R` script, including Python 3, cooler, h5py, hdf5plugin, numpy, R, and the required R/Bioconductor packages.

Create local working directories for input files, intermediate files, results, and logs:
```bash
mkdir -p data/h5 data/bedpe data/cool data/mcool results logs
```


## Configuration

This repository uses a local configuration file to avoid hard-coding user-specific paths, genome settings, and HPC/SLURM options inside the scripts.

Copy the example configuration file:
```bash
cp config/example.env config/local.env
```

Then edit it for your system:
```bash
nano config/local.env
```

The provided defaults are oriented toward the Drosophila dm6 genome assembly. If you use another genome, you must the following variables with values appropriate for your organism and genome assembly:
```bash
GENOME="dm6"
CHROM_SIZES="${PROJECT_DIR}/config/dm6.chrom.sizes.txt"
CHROMS="chr2L,chr2R,chr3L,chr3R,chrX"
```
The chromosome sizes file should contain two columns: **chromosome_name** and **chromosome_length**


## Execution

After installation and configuration, the workflow can be run either directly from the command line or submitted to a SLURM-based cluster.

### Local execution

Run the scripts directly using your local configuration file:
```bash
python scripts/h52bedpe.py config/local.env
bash scripts/bedpe2cool.sh config/local.env
bash scripts/cool2mcool.sh config/local.env
bash scripts/run_metaloops.sh config/local.env
```

### SLURM execution

SLURM submission templates are provided in the slurm/ directory. Before submitting jobs, check that the SLURM settings in config/local.env and/or the slurm/*.sbatch files match your HPC cluster.

Submit the jobs with:
```bash
sbatch slurm/h52bedpe.sbatch config/local.env
sbatch slurm/bedpe2cool.sbatch config/local.env
sbatch slurm/cool2mcool.sbatch config/local.env
sbatch slurm/metaloops.sbatch config/local.env
```

## Notes

- The conversion scripts are helper utilities for preparing Hi-C data for meta-loop calling.
- The actual meta-loop caller is the original `meta_loops.R` script from the Gambetta Lab `meta-loops-2022` repository.
- The provided SLURM scripts are examples and should be adapted to each user's HPC environment.
- The default genome settings are for Drosophila dm6.


## Credits
This project uses the script [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R) developed by Julien Dorier and the Lausanne University, available under license [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). The original repository can be found in [[meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main)].
