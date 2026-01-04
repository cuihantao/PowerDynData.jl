# Getting Started

## Installation

```julia
using Pkg
Pkg.add("PowerDynData")
```

## Basic Usage

### Parsing DYR Files

```julia
using PowerDynData
using DataFrames

# Parse DYR file - metadata loads automatically
dd = parse_dyr("case.dyr")

# Display overview
println(dd)
# Output:
# DynamicData from: case.dyr
#   Models: ESST3A, EXST1, GENROU, IEEEG1, IEEEST, ST2CUT, TGOV1
#   Metadata: loaded (34 model schemas)
#   Validation issues: 35 total (35 out-of-range)

# Access models with named fields
genrou_df = DataFrame(dd["GENROU"])

# Inspect available models
keys(dd)  # => ["GENROU", "ESST3A", "TGOV1", ...]
```

### TOML Format Support

PowerDynData also supports a TOML-based format as an alternative to DYR:

```julia
# Parse TOML file - same API as parse_dyr
dd = parse_toml("case.toml")

# Convert existing DYR file to TOML
dyr_to_toml("case.dyr", "case.toml")
```

**DYR format** (positional fields):
```
1 'GENCLS' 1   3.0  0.0 /
```

**TOML format** (named fields):
```toml
[[GENCLS]]
BUS = 1
ID = "1"
H = 3.0
D = 0.0
```

## Handling Validation Issues

PowerDynData tracks validation issues (out-of-range values, parse errors) without failing:

```julia
dd = parse_dyr("case.dyr")

# Check for validation issues
if !isempty(dd.validation_issues)
    println("Found $(length(dd.validation_issues)) validation issues")

    for issue in dd.validation_issues
        if issue.issue_type == :out_of_range
            println("$(issue.model_name)[$(issue.record_index)].$(issue.field_name) = $(issue.value)")
            println("  $(issue.message)")
        end
    end
end

# Note: Out-of-range values are still preserved in the data
```

## Working Without Metadata

For models without bundled metadata, PowerDynData falls back to indexed fields:

```julia
# Disable metadata to get indexed fields
dd = parse_dyr("case.dyr", metadata_dir=nothing)

# Models use IndexedDynamicRecords
genrou = dd["GENROU"]
genrou isa IndexedDynamicRecords  # true

# Access raw fields
genrou.fields[1]     # First record's fields
genrou.fields[1][8]  # Field 8 of first record (H for GENROU)
```

## Custom Metadata

You can provide custom metadata for proprietary or user-defined models:

```julia
# Create custom metadata directory structure:
# my_metadata/
#   custom_models/
#     MYMODEL.yaml

# Parse with custom metadata
dd = parse_dyr("case.dyr", metadata_dir="my_metadata")

# Models with custom metadata get named fields
mymodel = dd["MYMODEL"]
mymodel isa NamedDynamicRecords  # true
```

See the [Developer Guide](developers.md) for the YAML schema structure used in metadata files.
