#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import hdf5plugin
import h5py
import numpy as np

# Configure plugins HDF5
conda_prefix = os.environ.get("CONDA_PREFIX", "")
plugin_path = os.path.join(
    conda_prefix, 
    "lib/python3.10/site-packages/hdf5plugin/plugins"
)
os.environ["HDF5_PLUGIN_PATH"] = plugin_path

def h5_to_bedpe(h5_path, bedpe_path, min_count=0):
    try:
        with h5py.File(h5_path, "r") as f, open(bedpe_path, "w") as bedpe:
            # Load genomic intervals
            chr_list = f["intervals/chr_list"][:]
            start_list = f["intervals/start_list"][:]
            end_list = f["intervals/end_list"][:]
            
            # Load sparse matrix
            indptr = f["matrix/indptr"][:]
            indices = f["matrix/indices"][:]
            data = f["matrix/data"][:]
            shape = f["matrix/shape"][:]
            
            # Iterate over the sparse matrix
            for bin1 in range(shape[0]):
                start_idx = indptr[bin1]
                end_idx = indptr[bin1 + 1]
                cols = indices[start_idx:end_idx]
                counts = data[start_idx:end_idx]
                
                for bin2, count in zip(cols, counts):
                    if bin1 <= bin2 and count >= min_count:
                        chr1 = chr_list[bin1].decode("utf-8")
                        start1 = start_list[bin1]
                        end1 = end_list[bin1]
                        
                        chr2 = chr_list[bin2].decode("utf-8")
                        start2 = start_list[bin2]
                        end2 = end_list[bin2]
                        
                        bedpe.write(
                            f"{chr1}\t{start1}\t{end1}\t"
                            f"{chr2}\t{start2}\t{end2}\t"
                            f"{count}\n"
                        )
            
        print(f"Converted: {h5_path} -> {bedpe_path}")
        
    except Exception as e:
        print(f"ERROR in {h5_path}: {str(e)}")

def convert_all_h5_to_bedpe(min_count=0):
    # Get all h5 files in the current directory
    current_dir = os.getcwd()
    h5_files = [f for f in os.listdir(current_dir) if f.endswith(".h5")]
    
    if not h5_files:
        print("No h5 files found in the current directory.")
        return
    
    for h5_file in h5_files:
        # Generate bedpe filename
        base_name = os.path.splitext(h5_file)[0]
        bedpe_file = f"{base_name}.bedpe"
        
        # Convert
        h5_to_bedpe(h5_file, bedpe_file, min_count)

if __name__ == "__main__":
    convert_all_h5_to_bedpe(min_count=5)
