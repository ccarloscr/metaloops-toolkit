## [2.0.0] - 2026-05-11

### Added
- **Configuration System**: Centralized all project variables in `config/local.env`.
- **HPC Support**: Standardized SLURM `.sbatch` templates for cluster execution.
- **Workflow Automation**: Scripts now accept environment files as arguments for better reproducibility.
- **Improved Logging**: Added a dedicated `logs/` directory for SLURM and local execution outputs.

### Changed
- **Code Structure**: Revamped all conversion scripts to remove hardcoded paths.
- **Environment Management**: Transitioned to a more robust Conda activation method compatible with HPC shell profiles.

### Removed
- Hardcoded Drosophila `dm6` paths within script logic; these are now parameters in the `.env` file.

### ⚠️ Breaking Changes
- Scripts no longer run without a configuration file provided as an argument (e.g., `bash script.sh config/local.env`).
