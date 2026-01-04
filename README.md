# PowerDynData.jl

A Julia package for parsing PSS/E DYR (dynamics data) files with metadata-driven field naming.

[![Build Status](https://github.com/cuihantao/PowerDynData.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cuihantao/PowerDynData.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/cuihantao/PowerDynData.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cuihantao/PowerDynData.jl)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://cuihantao.github.io/PowerDynData.jl)

**[Documentation](https://cuihantao.github.io/PowerDynData.jl)** | **[Model Library](https://cuihantao.github.io/PowerDynData.jl/models/)** | **[API Reference](https://cuihantao.github.io/PowerDynData.jl/api/)**

## Features

- **Metadata-driven parsing**: YAML schemas define model structure with field names, types, units, and descriptions
- **Automatic metadata loading**: Bundled metadata for common PSS/E models loads by default
- **Dual-mode operation**: Works with or without metadata (named fields vs indexed fields)
- **Validation tracking**: Out-of-range values are preserved and tracked for user inspection
- **CIM-style metadata**: Rich field metadata including descriptions, units, types, and valid ranges
- **Tables.jl integration**: Seamless conversion to DataFrames
- **Flexible format handling**: Supports standard and user-defined PSS/E dynamic models
- **Robust parsing**: Handles multi-line records, scientific notation, comments, and edge cases

## Installation

```julia
using Pkg
Pkg.add("PowerDynData")
```

## Quick Start

### Basic Usage (Recommended)

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

## TOML Format Support

PowerDynData also supports a TOML-based format as an alternative to DYR. TOML provides self-documenting data with explicit field names, making it easier to read and version control.

### Parsing TOML Files

```julia
# Parse TOML file - same API as parse_dyr
dd = parse_toml("case.toml")

# Access models identically to DYR
genrou_df = DataFrame(dd["GENROU"])
```

### Converting DYR to TOML

```julia
# Convert existing DYR file to TOML
dyr_to_toml("case.dyr", "case.toml")
```

### DYR vs TOML: Side-by-Side Example

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

In DYR, fields are identified by position. In TOML, each field is explicit with `name = value`. Use `[[MODEL]]` (double brackets) to create an array - each `[[MODEL]]` block adds one device instance.

### TOML Format Syntax

```toml
# IEEE 14-bus dynamic data

# Each model instance uses [[MODEL_NAME]] syntax
[[GENROU]]
BUS = 1
ID = "1"
H = 4.0         # Inertia constant (MW·s/MVA)
D = 0.0         # Damping coefficient
Xd = 1.8        # Direct axis synchronous reactance
Xd1 = 0.6       # Direct axis transient reactance
Td10 = 6.5      # D-axis transient time constant
# ... additional fields

[[GENROU]]
BUS = 2
ID = "1"
H = 6.5
# ...

[[TGOV1]]
BUS = 1
ID = "1"
R = 0.05        # Permanent droop
T1 = 1.0        # Governor time constant
Vmax = 1.05     # Maximum valve position
Vmin = 0.3      # Minimum valve position
```

### DYR vs TOML Comparison

| Feature | DYR | TOML |
|---------|-----|------|
| Field identification | By position | By name |
| Comments | Limited | Full support (`#`) |
| Readability | Requires metadata reference | Self-documenting |
| Version control | Difficult diffs | Clean diffs |
| Type safety | All text | Native types |

Field names in TOML must match the metadata YAML definitions exactly (e.g., `H`, `Xd`, `Td10`).

## User-Facing API

### Main Functions

#### `parse_dyr(source; metadata_dir=pkgdir(PowerDynData, "metadata"))`

Parse a PSS/E DYR file into structured data.

**Arguments:**
- `source`: Path to DYR file or IO object
- `metadata_dir`: Path to metadata directory (default: bundled metadata). Set to `nothing` to disable metadata.

**Returns:** `DynamicData` container with all parsed models

```julia
dd = parse_dyr("case.dyr")
```

#### `parse_toml(source; metadata_dir=pkgdir(PowerDynData, "metadata"))`

Parse a TOML file into structured data. Same return type and API as `parse_dyr`.

```julia
dd = parse_toml("case.toml")
```

#### `dyr_to_toml(dyr_source, toml_dest; metadata_dir=...)`

Convert a DYR file to TOML format.

```julia
dyr_to_toml("case.dyr", "case.toml")
```

### Data Structures

#### `DynamicData`

Top-level container for all dynamic data from a DYR file.

**Fields:**
- `models::Dict{String, DynamicRecords}` - Dictionary of model records by name
- `metadata_registry::Union{MetadataRegistry, Nothing}` - Loaded metadata (if any)
- `source_file::String` - Path to source DYR file
- `validation_issues::Vector{ValidationIssue}` - Validation problems encountered during parsing

**Accessors:**
```julia
dd["GENROU"]           # Get model by name
keys(dd)               # List all model names
haskey(dd, "GENROU")   # Check if model exists
length(dd)             # Number of model types
```

#### `NamedDynamicRecords`

Dynamic records with metadata-driven named fields.

**Fields:**
- `model_name::String` - Model name (e.g., "GENROU")
- `category::String` - Model category (e.g., "generator")
- `data::StructArray` - Column-oriented data with named fields

**Usage:**
```julia
genrou = dd["GENROU"]
genrou isa NamedDynamicRecords  # true

# Access as StructArray
genrou.data.H        # Inertia constant for all units
genrou.data.BUS      # Bus numbers for all units

# Convert to DataFrame
df = DataFrame(genrou)
```

#### `IndexedDynamicRecords`

Dynamic records without metadata (fallback mode).

**Fields:**
- `model_name::String` - Model name
- `fields::Vector{Vector{Any}}` - Raw field data as vectors

**Usage:**
```julia
# When metadata not available for a model
custom = dd["CustomModel"]
custom isa IndexedDynamicRecords  # true

# Access raw fields
custom.fields[1]  # First record's fields
```

#### `ValidationIssue`

Represents a validation problem encountered during parsing.

**Fields:**
- `model_name::String` - Model where issue occurred
- `record_index::Int` - Record index (1-based) within the model
- `field_name::Symbol` - Field name where issue occurred
- `issue_type::Symbol` - Type of issue (`:out_of_range`, `:parse_error`)
- `message::String` - Human-readable description
- `value::Any` - The actual value that caused the issue

**Issue Types:**
- `:out_of_range` - Value parsed successfully but outside valid range (value is still stored)
- `:parse_error` - Failed to parse the field value (default value used instead)

**Usage:**
```julia
# Check for validation issues
println(dd)  # Shows issue count in summary

# Inspect specific issues
for issue in dd.validation_issues
    if issue.issue_type == :out_of_range
        println("$(issue.model_name)[$(issue.record_index)].$(issue.field_name) = $(issue.value)")
        println("  $(issue.message)")
    end
end

# Group by model
by_model = Dict{String, Int}()
for issue in dd.validation_issues
    by_model[issue.model_name] = get(by_model, issue.model_name, 0) + 1
end
```

### Metadata System

#### `load_metadata_registry(metadata_dir)`

Load YAML metadata schemas from a directory.

```julia
# Load bundled metadata
registry = load_metadata_registry(pkgdir(PowerDynData, "metadata"))

# Inspect loaded models
keys(registry.models)  # => ["GENROU", "GENCLS", "TGOV1", ...]

# Get metadata for a specific model
genrou_meta = registry.models["GENROU"]
println(genrou_meta.description)  # "Round rotor generator model"
println(genrou_meta.category)     # "generator"

# Inspect field metadata
for field in genrou_meta.fields
    println("$(field.name): $(field.description) [$(field.unit)]")
end
```

## Complete Examples

### Example 1: Basic Parsing and DataFrame Conversion

```julia
using PowerDynData
using DataFrames

# Parse DYR file
dd = parse_dyr("ieee14.dyr")

# Display overview
println(dd)
# Output:
# DynamicData from: ieee14.dyr
#   Models: ESST3A, EXST1, GENROU, IEEEG1, IEEEST, ST2CUT, TGOV1
#   Metadata: loaded (34 model schemas)
#   Validation issues: 35 total (35 out-of-range)

# Convert GENROU to DataFrame
genrou_df = DataFrame(dd["GENROU"])

# Work with data
println(nrow(genrou_df))           # Number of GENROU units
println(names(genrou_df))          # Column names
println(genrou_df.H)               # Inertia constants
println(genrou_df[1, :])           # First record
```

### Example 2: Handling Validation Issues

```julia
using PowerDynData

dd = parse_dyr("case.dyr")

# Check if there are validation issues
if !isempty(dd.validation_issues)
    println("Found $(length(dd.validation_issues)) validation issues")

    # Group by model
    by_model = Dict{String, Int}()
    for issue in dd.validation_issues
        by_model[issue.model_name] = get(by_model, issue.model_name, 0) + 1
    end

    println("\nIssues by model:")
    for (model, count) in sort(collect(by_model))
        println("  $model: $count issues")
    end

    # Show first 5 out-of-range issues
    println("\nFirst 5 out-of-range issues:")
    count = 0
    for issue in dd.validation_issues
        if issue.issue_type == :out_of_range && count < 5
            println("  $(issue.model_name)[$(issue.record_index)].$(issue.field_name):")
            println("    Value: $(issue.value)")
            println("    $(issue.message)")
            count += 1
        end
    end

    # Note: Out-of-range values are still in the data!
    esst3a = dd["ESST3A"]
    df = DataFrame(esst3a)
    println("\nActual VRMAX values (including out-of-range):")
    println(df.VRMAX)  # [99.0, 99.0, ...] - actual values preserved
end
```

### Example 3: Working Without Metadata

```julia
using PowerDynData

# Disable metadata to get indexed fields
dd = parse_dyr("case.dyr", metadata_dir=nothing)

# Models use IndexedDynamicRecords
genrou = dd["GENROU"]
genrou isa IndexedDynamicRecords  # true

# Access raw fields
println("Number of records: $(length(genrou))")
println("First record fields: $(genrou.fields[1])")
println("Field 2 of first record: $(genrou.fields[1][2])")  # Model name
println("Field 8 of first record: $(genrou.fields[1][8])")  # H (inertia)
```

### Example 4: Custom Metadata

```julia
using PowerDynData

# Create custom metadata directory
# my_metadata/
#   custom_models/
#     MYMODEL.yaml

# Parse with custom metadata
dd = parse_dyr("case.dyr", metadata_dir="my_metadata")

# Models with custom metadata get named fields
mymodel = dd["MYMODEL"]
mymodel isa NamedDynamicRecords  # true

# Models without metadata fall back to indexed
other = dd["OtherModel"]
other isa IndexedDynamicRecords  # true (no metadata found)
```

## Metadata System

PowerDynData uses YAML files to define model schemas with CIM-style metadata.

### Example Metadata File

**`metadata/generators/GENROU.yaml`**

```yaml
model:
  name: GENROU
  description: Round rotor generator model
  category: generator
  version: 33

parsing:
  model_name_field: 2           # Field position of model name
  multi_line: true              # Spans multiple lines
  line_count: 3                 # Number of lines
  terminator: "/"              # End-of-record marker

fields:
  - name: BUS
    position: 1
    type: Int
    description: "Bus number where generator is connected"
    unit: dimensionless
    required: true

  - name: H
    position: 8
    type: Float64
    description: "Inertia constant"
    unit: "MW·s/MVA"
    required: true
    range: [0.0, Inf]

  # ... more fields
```

### Creating Your Own Metadata

1. Create a YAML file in the appropriate category folder (e.g., `metadata/generators/`)
2. Define model properties, parsing rules, and field metadata
3. Include descriptions, units, types, and validation ranges
4. Use the metadata with `parse_dyr(..., metadata_dir="metadata")`

See the [plan document](../PowerDyrData_PLAN.md) for complete metadata schema specification.

### Bundled Metadata

PowerDynData includes metadata for common PSS/E models:

**Generators:**
- GENROU, GENSAL, GENCLS

**Exciters:**
- ESST3A, ESST1A, ESST4B, EXST1, EXAC1, EXAC2, EXAC4, EXDC2, ESAC1A, ESDC1A, ESDC2A, IEEET1, IEEEX1, AC8B, SEXS

**Governors:**
- TGOV1, IEEEG1

**Stabilizers:**
- IEEEST, ST2CUT

## Package Structure

```
PowerDynData/
├── src/
│   ├── PowerDynData.jl       # Main module
│   ├── types.jl               # Data structures
│   ├── metadata.jl            # YAML schema handling
│   ├── parsing.jl             # Core parsing logic
│   ├── debug.jl               # Debug utilities
│   └── precompile.jl          # Precompilation workload
├── metadata/                  # YAML schemas by category
│   ├── generators/
│   ├── exciters/
│   ├── governors/
│   └── stabilizers/
├── test/
│   ├── runtests.jl
│   └── testfiles/
└── docs/
```

## Current Status

**Phase 1: Infrastructure** ✓
- [x] Package scaffolding with PkgTemplates
- [x] Type system (DynamicData, DynamicRecords)
- [x] Metadata system (YAML loading, validation)
- [x] Full DYR file parser implementation
- [x] Multi-line record handling
- [x] Validation issue tracking
- [x] Automatic metadata loading
- [x] Example metadata files for common models
- [x] Test framework
- [x] All tests passing (62/62)

**Phase 2: Enhancement** (Next)
- [ ] Performance optimization
- [ ] Extended metadata library (more PSS/E models)
- [ ] Documentation site
- [ ] CI/CD workflows

## Architecture Highlights

### Three-Layer Design

1. **Metadata Layer**: YAML schemas define structure
2. **Parsing Layer**: Flexible parser handles various formats
3. **Data Layer**: Column-oriented storage with Tables.jl

### Key Design Decisions

- **Metadata-driven**: Easy to add new models without code changes
- **Automatic fallback**: Robust parsing even without metadata for specific models
- **Validation tracking**: Out-of-range values preserved, issues tracked for inspection
- **Tables.jl integration**: Zero-copy DataFrame conversion
- **StructArrays**: Memory-efficient column-oriented storage

## Contributing

Contributions welcome! Areas of interest:

1. **Metadata expansion**: Add YAML schemas for more PSS/E models
2. **Testing**: Add more edge case tests
3. **Documentation**: User guides and examples
4. **Performance**: Optimize parsing for large files

## Related Projects

- **[PowerFlowData.jl](https://github.com/cuihantao/PowerFlowData.jl)**: PSS/E RAW file parser
- **[Powerful.jl](https://github.com/cuihantao/Powerful.jl)**: Power systems simulation package
- **[PowerSystems.jl](https://nrel-sienna.github.io/PowerSystems.jl/stable/explanation/dynamic_data/)**: PowerSystems Data Handling Package

## License

MIT License - see LICENSE file for details.

## Acknowledgments

Inspired by:
- PowerFlowData.jl's efficient parsing architecture
- ANDES's YAML-based metadata system
- CIM (Common Information Model) metadata standards
