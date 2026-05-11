#!/usr/bin/env python3

"""
h5_to_bedpe.py — Convert Hi-C .h5 files to BEDPE format.

Usage: use the shell wrapper script
    bash scripts/h5_to_bedpe_wrapper.sh config/local.env
    bash submit.sh scripts/h5_to_bedpe_wrapper.sh config/local.env

The HDF5 plugin path is resolved automatically from the active conda environment.
"""

import argparse
import os
import sys
from pathlib import Path

import h5py
import hdf5plugin


def resolve_hdf5_plugin_path() -> None:
    """
    Point HDF5_PLUGIN_PATH at the hdf5plugin plugins directory inside the
    active environment, without assuming a specific Python version.
    Falls back if hdf5plugin cannot locate its own data files.
    """
    try:
        plugin_dir = Path(hdf5plugin.__file__).parent / "plugins"
        if plugin_dir.is_dir():
            os.environ["HDF5_PLUGIN_PATH"] = str(plugin_dir)
    except Exception:
        pass  # hdf5plugin is already imported; HDF5 will still find its plugins


def h5_to_bedpe(h5_path: Path, bedpe_path: Path, min_count: int = 0) -> bool:
    """
    Convert a single .h5 Hi-C matrix to BEDPE format.

    Returns True on success, False on failure.
    """
    try:
        with h5py.File(h5_path, "r") as f, bedpe_path.open("w") as bedpe:

            # Validate expected HDF5 schema
            required_paths = [
                "intervals/chr_list",
                "intervals/start_list",
                "intervals/end_list",
                "matrix/indptr",
                "matrix/indices",
                "matrix/data",
                "matrix/shape"
            ]
    
            missing = [p for p in required_paths if p not in f]
    
            if missing:
                raise ValueError(
                    "Unsupported HDF5 schema.\n"
                    f"Missing datasets: {missing}\n"
                    "This script currently supports only "
                    "MetaLoops-compatible sparse CSR Hi-C HDF5 files."
                )
    
            # Load datasets
            chr_list  = f["intervals/chr_list"][:]
            start_list = f["intervals/start_list"][:]
            end_list   = f["intervals/end_list"][:]

            indptr  = f["matrix/indptr"][:]
            indices = f["matrix/indices"][:]
            data    = f["matrix/data"][:]
            shape   = f["matrix/shape"][:]

            n_written = 0
            for bin1 in range(shape[0]):
                start_idx = indptr[bin1]
                end_idx   = indptr[bin1 + 1]
                cols   = indices[start_idx:end_idx]
                counts = data[start_idx:end_idx]

                for bin2, count in zip(cols, counts):
                    if bin1 <= bin2 and count >= min_count:
                        chr1   = chr_list[bin1].decode("utf-8")
                        start1 = start_list[bin1]
                        end1   = end_list[bin1]

                        chr2   = chr_list[bin2].decode("utf-8")
                        start2 = start_list[bin2]
                        end2   = end_list[bin2]

                        bedpe.write(
                            f"{chr1}\t{start1}\t{end1}\t"
                            f"{chr2}\t{start2}\t{end2}\t"
                            f"{count}\n"
                        )
                        n_written += 1

        print(f"  OK  {h5_path.name} -> {bedpe_path.name}  ({n_written} contacts)")
        return True

    except Exception as exc:
        print(f"  ERROR  {h5_path.name}: {exc}", file=sys.stderr)
        return False


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert Hi-C .h5 files to BEDPE format."
    )
    parser.add_argument(
        "--input-dir", "-i",
        type=Path,
        default=Path("h5_files"),
        help="Directory containing input .h5 files (default: h5_files)",
    )
    parser.add_argument(
        "--output-dir", "-o",
        type=Path,
        default=Path("bedpe_files"),
        help="Directory where .bedpe files will be written (default: bedpe_files)",
    )
    parser.add_argument(
        "--min-count", "-m",
        type=int,
        default=0,
        help="Minimum contact count to include (default: 0)",
    )
    args = parser.parse_args()

    resolve_hdf5_plugin_path()

    if not args.input_dir.is_dir():
        print(f"ERROR: Input directory not found: {args.input_dir}", file=sys.stderr)
        sys.exit(1)

    args.output_dir.mkdir(parents=True, exist_ok=True)

    h5_files = sorted(args.input_dir.glob("*.h5"))
    if not h5_files:
        print(f"ERROR: No .h5 files found in {args.input_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"Input dir  : {args.input_dir}")
    print(f"Output dir : {args.output_dir}")
    print(f"Min count  : {args.min_count}")
    print(f"Files found: {len(h5_files)}")
    print("─" * 44)

    failed = []
    for h5_file in h5_files:
        bedpe_file = args.output_dir / h5_file.with_suffix(".bedpe").name
        success = h5_to_bedpe(h5_file, bedpe_file, args.min_count)
        if not success:
            failed.append(h5_file.name)

    print("═" * 44)
    if failed:
        print(f"Completed with {len(failed)} error(s):")
        for f in failed:
            print(f"  - {f}")
        sys.exit(1)
    else:
        print(f"h5_to_bedpe complete. All files written to: {args.output_dir}")


if __name__ == "__main__":
    main()
