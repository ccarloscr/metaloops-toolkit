#!/bin/bash

#SBATCH --job-name=bedpe2cool
#SBATCH --partition=irbio01         
#SBATCH --nodes=1                   
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=24          
#SBATCH --output=bedpe2cool_%j.out  
#SBATCH --error=bedpe2cool_%j.err   


# Configuration
source /etc/profile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace


# Variable set up
input_dir="bedpe_files"
output_dir="cool_files"
chrom_sizes="dm6.chrom.sizes.txt"
resolution=4000
blacklist_chr="chrM|chrY"


# Checks
[ ! -d "$input_dir" ] && echo "ERROR: Directory $input_dir does not exist" && exit 1
[ ! -f "$chrom_sizes" ] && echo "ERROR: chrom.sizes not found" && exit 1
command -v cooler >/dev/null || { echo "Install cooler: pip install cooler"; exit 1; }
mkdir -p "$output_dir"


# Processing files
for bedpe_file in "$input_dir"/*.bedpe; do
    filename=$(basename "$bedpe_file")
    output_name="${filename%.bedpe}.cool"
    output_path="$output_dir/$output_name"
    echo "Processing: $filename -> $output_name"
    
    # Step 1: Filtering and converting BEDPE to COOL
    grep -Ev "$blacklist_chr" "$bedpe_file" | \
    awk -F '\t' -v res="$resolution" '
        BEGIN {OFS="\t"}
        {
            mid1 = int(($2 + $3)/2)  # Centro del bin
            mid2 = int(($5 + $6)/2)
            print $1, mid1, $4, mid2, $7  # chr1, pos1, chr2, pos2, count
        }' | \
    # Step 2: Convert to COOL format
    cooler cload pairs \
        --assembly dm6 \
        --chrom1 1 \
        --pos1 2 \
        --chrom2 3 \
        --pos2 4 \
        "$chrom_sizes:$resolution" \
        - \
	"$output_path"

    # Step 3: Normalize  COOL file
    if [ -f "$output_path" ]; then
        cooler balance --force --cis-only "$output_path"
    else
        echo "ERROR: Could not generate $output_path"
        exit 1
    fi

    echo "Generated file: $output_path"
done

echo "Conversion complete."
