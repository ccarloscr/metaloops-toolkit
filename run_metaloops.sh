#!/bin/bash

#SBATCH --job-name=meta_loops       # Job name
#SBATCH --partition=irbio01         # Partition name
#SBATCH --nodes=1                   # Number of nodes
#SBATCH --ntasks=1                  # Number of tasks
#SBATCH --cpus-per-task=12          # CPUs
#SBATCH --output=meta_loops_%j.out  # Output log
#SBATCH --error=meta_loops_%j.err   # Error log

# System set up
source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace
conda install -c conda-forge fftw r-fftwtools -y

# Install R packages
echo "Installing packages..."
Rscript install_packages.R

# Initiate metaloops script
echo "Initiating meta loops..."
Rscript meta_loops.R --output=2k_Sample_1-meta-loops.tsv --resolution=2000 --chrs=chr2L,chr2R,chr3L,chr3R,chr4,chrX Sample_1.mcool
Rscript meta_loops.R --output=2k_Sample_2-meta-loops.tsv --resolution=2000 --chrs=chr2L,chr2R,chr3L,chr3R,chr4,chrX Sample_2.mcool
