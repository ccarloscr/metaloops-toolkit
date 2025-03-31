# metaloops-25

This repository contains all the necessary scripts to download bedpe.gz files from Hi-C experiments, process them into mcool files, merge replicates and run [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R).

## Installation


## Configuration
The main script run_script.sh calls the other script when needed:

1- Input files: input files can be provided in bedpe.gz, cool or mcool format. Alternatively, a metadata file containing urls can be provided to download the files.
2- Conversion: if files provided are not in cool nor mcool formats, they are converted into cool files.
3- Merge of replicates: if 

1- Download files: only if a url-containing file is provided.
2- Convert bedpe.gz files to cool files: 


- Get bedpe files
- Convert to cool files
- Merge relicates
- Convert to mcool
- Run metaloops




## Credits
This project uses the script [metaloops.sh](https://github.com/ccarloscr/metaloops-25/blob/main/meta_loops.R) developed by Julien Dorier and the Lausanne University, available under license [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). The original repository can be found in [[meta-loops-2022](https://github.com/gambettalab/meta-loops-2022/tree/main)].
