# INSPECTA-Codebuild-CI-Action

INSPECTA CI action to conduct Verus analysis on a Rust implementations.

## Inputs

### `sourcepath`

Path to top level Makefile (expects path string).

### `environment-variables`

JSON-formatted dictionary of environment variables to pass to the make system.

### `report-filename`

The name of the file into which to write the JSON-formatted code generation analysis report.  Default: 'codegen-report.json'.

## Outputs

## `result`

The JSON-formatted summary of analysis results.

## Example usage

uses: actions/INSPECTA-Codebuild-CI-Action@v1
with:
  sourcepath: 'system/hamr/microkit'
