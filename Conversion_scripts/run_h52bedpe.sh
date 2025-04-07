#!/bin/bash

#SBATCH --job-name=h52bedpe
#SBATCH --partition=irbio01
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --output=h52bedpe_%j.out
#SBATCH --error=h52bedpe_%j.err

# Configuration
source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace

# Run python script
python h52bedpe.py
