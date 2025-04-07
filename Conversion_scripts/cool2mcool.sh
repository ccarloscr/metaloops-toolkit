#!/bin/bash

#SBATCH --job-name=cool2mcool
#SBATCH --partition=irbio01
#SBATCH --nodes=1 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --output=cool2mcool_%j.out
#SBATCH --error=cool2mcool_%j.err

# Configuration
source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate metaloops

# Set input directory
INPUT_DIR=."/cool_files"
if [ ! -d "$INPUT_DIR" ]; then
    echo "Input directory $INPUT_DIR does not exist."
    exit 1
fi


# Process cool files
for input_cool in $INPUT_DIR/*.cool
do
    # Generate ouput name
    output_mcool="${input_cool%.cool}.mcool"
    resolutions="2000,4000,8000,10000,20000"

    echo "Processing: $input_cool -> $output_mcool"

    # Step 1: Generate mcool
    cooler zoomify \
        --resolutions "$resolutions" \
        --nproc 24 \
        -o "$output_mcool" \
        "$input_cool"

    # Step 2: Balance the mcool file
    for res in ${resolutions//,/ }; do
        cooler_path="$output_mcool::resolutions/$res"
                
        echo "Balancing $res bp..."
        
        cooler balance \
            --cis-only \
            --max-iters 500 \
            --tol 0.01 \
            --force \
            "$cooler_path" || \
        echo "ERROR: Balancing failed for $cooler_path."
    done
    
    echo "File generated: $output_mcool"
    ls -lh "$output_mcool"
done

echo "Processing completed."
