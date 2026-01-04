```@meta
CurrentModule = PowerDynData
```

# PowerDynData.jl

A Julia package for parsing PSS/E DYR (dynamics data) files with metadata-driven field naming.

## Features

- **Metadata-driven parsing**: YAML schemas define model structure with field names, types, units, and descriptions
- **Automatic metadata loading**: Bundled metadata for common PSS/E models loads by default
- **Dual-mode operation**: Works with or without metadata (named fields vs indexed fields)
- **Validation tracking**: Out-of-range values are preserved and tracked for user inspection
- **Tables.jl integration**: Seamless conversion to DataFrames
- **TOML format support**: Alternative self-documenting format with DYR-to-TOML conversion

## Quick Example

```julia
using PowerDynData
using DataFrames

# Parse DYR file - metadata loads automatically
dd = parse_dyr("case.dyr")

# Access models with named fields
genrou_df = DataFrame(dd["GENROU"])
tgov1_df = DataFrame(dd["TGOV1"])

# Inspect available models
keys(dd)  # => ["GENROU", "ESST3A", "TGOV1", "GENCLS", ...]
```

## Documentation

```@contents
Pages = [
    "getting_started.md",
    "models/index.md",
    "api.md",
]
Depth = 2
```

## Navigation

- **[Getting Started](@ref)**: Installation and basic usage
- **[Model Library](models/index.md)**: Complete reference for all supported dynamic models
- **[API Reference](@ref)**: Function and type documentation
