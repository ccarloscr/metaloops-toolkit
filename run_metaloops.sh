#!/bin/bash

#SBATCH --job-name=meta_loops
#SBATCH --partition=irbio01 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --output=meta_loops_%j.out
#SBATCH --error=meta_loops_%j.err

source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace

echo "Installing packages..."
Rscript install_packages.R

echo "Initiating meta loops..."

# Define the main directory to search for .mcool files
MAIN_DIR="/metaloops-25/mcool_files"

# Loop through all .mcool files in the main directory and its subdirectories
find "$MAIN_DIR" -type f -name "*.mcool" | while read -r mcool_file; do
    # Extract the base name of the file
    base_name=$(basename "$mcool_file" .mcool)
    echo "Running metaloops for $mcool_file"
    # Run the Rscript command for each .mcool file
    Rscript meta_loops.R --output="${base_name}-meta-loops.tsv" --resolution=2000 --chrs=chr2L,chr2R,chr3L,chr3R,chr4,chrX "$mcool_file"
done


