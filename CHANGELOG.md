## [2.0.0] - 2026-05-11

### Added
- **HPC Support**: New SLURM `.sbatch` templates and a unified execution logic.
- **Configuration System**: Centralized settings in `config/local.env` to avoid hardcoding paths.
- **Validation**: Added usage help and input checks to all shell scripts.

### Changed
- **Environment Management**: Updated to a more robust `conda` activation method using shell profiles.

### Removed
- Hardcoded SLURM headers inside processing scripts (now handled via the config wrapper).

### ⚠️ Breaking Changes
- Scripts now require a path to a `.env` file as the first argument.
- Previous standalone execution without a config file is no longer supported.
