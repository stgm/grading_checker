## [Unreleased]

## [0.1.0] - 2025-02-24

- Initial release of `GradingChecker`.
- Validates `grading.yml` and `submit.yml` configuration files.
- Checks for duplicate submission names in `submit.yml`.
- Ensures a valid `grading.yml` structure in the root directory and subdirectories.
- Reports errors and provides clear feedback on misconfigurations.
- Supports command-line execution with an optional directory argument.
- Added `--help` flag to display usage instructions.
- Returns appropriate exit codes (`0` for success, `1` for validation errors).
