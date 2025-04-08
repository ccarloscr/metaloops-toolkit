#!/bin/bash

#SBATCH --job-name=meta_loops
#SBATCH --partition=irbio01 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --output=meta_loops_%j.out
#SBATCH --error=meta_loops_%j.err


# System set up
source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metaloops


# Variable set up
MAIN_DIR="./metaloops-25/mcool_files"
RESOLUTION=4000
CHROMOSOMES="chr2L,chr2R,chr3L,chr3R,chr4,chrX,chrY"
OUTPUT_DIR="Results"

# Create Results directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through all .mcool files in the main directory and its subdirectories
find "$MAIN_DIR" -type f -name "*.mcool" | while read -r mcool_file; do
    echo "Processing: $mcool_file"
    
    # Extract the base name of the file
    base_name=$(basename "$mcool_file" .mcool)
    output_file="${OUTPUT_DIR}/${base_name}-meta-loops.tsv"

    # Check if output already exists
    if [ -f "$output_file" ]; then
        echo "File $output_file already exists. Skipping."
        continue
    fi

    # Run the Rscript command for each .mcool file

    if Rscript meta_loops.R --output="$output_file" --resolution=$RESOLUTION --chrs="$CHROMOSOMES" "$mcool_file"; then
        echo "$mcool_file processed correctly."
    else
        echo "ERROR: Failed to process $mcool_file" >&2
    fi
done

echo "Process completed!"
