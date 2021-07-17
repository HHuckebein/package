# Package

[![Swift](https://github.com/HHuckebein/package/actions/workflows/swift.yml/badge.svg)](https://github.com/HHuckebein/package/actions/workflows/swift.yml)
[![codecov](https://codecov.io/gh/HHuckebein/package/branch/main/graph/badge.svg)](https://codecov.io/gh/HHuckebein/package)

**package** adds or updates the .binaryFramework section of a Package.swift file.
It supports local and remote binary targets.

## Usage
Depending on your use case:
- framework artefact is stored together with the repo
```
    package write-local-binary target --name <name> --path <path>
```
or framework artefact is stored on a remote location
```
    package write-remote-binary-target --name <name> --url <url> --check-sum <check-sum>
```
Both subcommands accept additional parameter as where the Package.swift file is located **--package-url** (defaults to current working path)
or **--output-directory** (defaults to --package-url).

### Debug Mode

The flag forces the output to be printed to the console instead of writing it to a file.

```
    --debug
```

### Code Coverage

```
    ./Support/showCoverage.sh
```

### Set Build Identifier

```
    ./Support/setBuildIdentifier.sh
```
