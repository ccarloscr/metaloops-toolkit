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
├── Conversion_scripts/
│   ├── h52bedpe.py
│   ├── run_h52bedpe.sh
│   ├── bedpe2cool.sh
│   ├── cool2mcool.sh
│   └── dm6.chrom.sizes.txt
├── environment.yml
├── meta_loops.R
├── run_metaloops.sh
├── LICENSE
└── README.md
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

Create the conda environment:
```bash
conda env create -f environment.yml
```


## Configuration

The scripts on this reposition are configured to run using SLURM. Change the scripts' headers according to your preferred job manager.


## Credits
This project uses the script [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R) developed by Julien Dorier and the Lausanne University, available under license [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). The original repository can be found in [[meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main)].
