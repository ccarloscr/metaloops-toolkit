#!/bin/bash

#SBATCH --job-name=meta_loops       # Nombre del trabajo
#SBATCH --partition=irbio01         # Nombre de la partición
#SBATCH --nodes=1                   # Número de nodos
#SBATCH --ntasks=1                  # Número de tareas
#SBATCH --cpus-per-task=12          # CPUs por tarea
#SBATCH --output=meta_loops_%j.out  # Archivo de salida
#SBATCH --error=meta_loops_%j.err   # Archivo de errores

source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace
conda install -c conda-forge fftw r-fftwtools -y

echo "Installing packages..."
Rscript install_packages.R

echo "Initiating meta loops..."
Rscript meta_loops.R --output=2k_CTL-meta-loops.tsv --resolution=2000 --chrs=chr2L,chr2R,chr3L,chr3R,chr4,chrX CTRL_1000_balanced.mcool
Rscript meta_loops.R --output=2k_REGE-meta-loops.tsv --resolution=2000 --chrs=chr2L,chr2R,chr3L,chr3R,chr4,chrX REGE_1000_balanced.mcool
