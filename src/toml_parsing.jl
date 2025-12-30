# TOML parsing for dynamic data
# Alternative to DYR format with explicit field names

"""
    parse_toml(source; metadata_dir=pkgdir(PowerDynData, "metadata")) -> DynamicData

Parse a TOML file containing dynamic model data into structured data.

# Arguments
- `source`: Path to TOML file or IO object
- `metadata_dir`: Path to metadata directory. Defaults to bundled metadata at
  `pkgdir(PowerDynData, "metadata")`. Set to `nothing` to disable metadata and
  use indexed fields only.

# Returns
- `DynamicData`: Container with all parsed models (same structure as `parse_dyr`)

# TOML Format Specification

The TOML format uses arrays of tables to represent multiple instances of each model type.
Each table entry corresponds to one device record.

## Structure
- **Model arrays**: Use `[[MODEL_NAME]]` syntax (double brackets) for each device instance
- **Field names**: Must match metadata YAML field names exactly (case-sensitive)
- **Comments**: Use `#` for comments (preserved in TOML, unlike DYR format)
- **Types**: TOML preserves native types (Int, Float64, String, Bool)

## Field Types
- **Integer fields**: `BUS = 1` (no quotes, no decimal)
- **Float fields**: `H = 4.0` or `H = 4` (integers auto-promoted to Float64)
- **String fields**: `ID = "1"` (double quotes required)
- **Boolean fields**: `enabled = true` or `enabled = false`

## Example File
```toml
# IEEE 14-bus dynamic data
# Comments are supported and encouraged

# Generator models - 5 GENROU units
[[GENROU]]
BUS = 1
ID = "1"
Td10 = 6.5      # Direct axis transient time constant
Td20 = 0.06     # Direct axis subtransient time constant
Tq10 = 0.2      # Quadrature axis transient time constant
Tq20 = 0.05     # Quadrature axis subtransient time constant
H = 4.0         # Inertia constant (MW·s/MVA)
D = 0.0         # Damping coefficient
Xd = 1.8        # Direct axis synchronous reactance
Xq = 1.75       # Quadrature axis synchronous reactance
Xd1 = 0.6       # Direct axis transient reactance
Xq1 = 0.8       # Quadrature axis transient reactance
Xd2 = 0.23      # Direct axis subtransient reactance
Xl = 0.15       # Leakage reactance
S10 = 0.09      # Saturation factor at 1.0 pu
S12 = 0.38      # Saturation factor at 1.2 pu

[[GENROU]]
BUS = 2
ID = "1"
# ... (remaining fields)

# Governor models - TGOV1 steam turbine governors
[[TGOV1]]
BUS = 1
ID = "1"
R = 0.05        # Permanent droop (pu)
Dt = 0.05       # Turbine damping coefficient (pu)
Vmax = 1.05     # Maximum valve position (pu)
Vmin = 0.3      # Minimum valve position (pu)
T1 = 1.0        # Governor time constant (s)
T2 = 2.1        # Turbine time constant (s)
T3 = 0.0        # Valve positioner time constant (s)
```

## Validation
- Unknown fields generate warnings but parsing continues
- Out-of-range values are recorded as validation issues (accessible via `dd.validation_issues`)
- Missing required fields are recorded as validation issues
- Type mismatches attempt conversion; failures recorded as parse errors

## Comparison with DYR Format
| Feature | DYR | TOML |
|---------|-----|------|
| Field identification | By position | By name |
| Comments | Limited (`@!`, `//`) | Full support (`#`) |
| Readability | Requires metadata reference | Self-documenting |
| Version control | Difficult diffs | Clean diffs |
| Type safety | All text | Native types |

# Examples
```julia
# Parse TOML file
dd = parse_toml("case.toml")

# Access models (same API as DYR)
genrou = dd["GENROU"]
df = DataFrame(genrou)

# Check validation issues
if !isempty(dd.validation_issues)
    for issue in dd.validation_issues
        @warn "Validation: \$(issue.model_name).\$(issue.field_name): \$(issue.message)"
    end
end

# Without metadata (indexed fallback)
dd = parse_toml("case.toml", metadata_dir=nothing)
```

See also: [`parse_dyr`](@ref), [`dyr_to_toml`](@ref)
"""
function parse_toml(
    source::Union{String, IO};
    metadata_dir::Union{String, Nothing} = pkgdir(PowerDynData, "metadata")
)::DynamicData
    # Load metadata if provided
    registry = isnothing(metadata_dir) ? nothing : load_metadata_registry(metadata_dir)

    # Get source file path
    source_path = source isa String ? source : "<IO>"

    # Parse TOML content
    content = source isa String ? TOML.parsefile(source) : TOML.parse(source)

    @pdebug 1 "Parsing TOML file: $source_path"

    # Process each model type
    models = Dict{String, DynamicRecords}()
    validation_issues = ValidationIssue[]

    for (model_name, records) in content
        # Skip non-array entries (could be metadata section in future)
        if !(records isa Vector)
            @pdebug 2 "Skipping non-array entry: $model_name"
            continue
        end

        @pdebug 2 "Processing model: $model_name ($(length(records)) records)"

        metadata = isnothing(registry) ? nothing : get_model_metadata(registry, model_name)

        if isnothing(metadata)
            # Fallback: indexed fields
            models[model_name] = create_indexed_records_from_toml(model_name, records)
        else
            # Use metadata for named fields with validation
            models[model_name] = create_named_records_from_toml(
                model_name, metadata, records, validation_issues
            )
        end
    end

    @pdebug 1 "Created $(length(models)) model types"
    @pdebug 1 "Encountered $(length(validation_issues)) validation issues"

    return DynamicData(models, registry, source_path, validation_issues)
end

"""
    create_named_records_from_toml(model_name, metadata, records, validation_issues) -> NamedDynamicRecords

Create NamedDynamicRecords from TOML parsed data using metadata schema.
"""
function create_named_records_from_toml(
    model_name::String,
    metadata::ModelMetadata,
    records::Vector,
    validation_issues::Vector{ValidationIssue}
)::NamedDynamicRecords
    # Pre-compute known fields for unknown field detection
    known_fields = Set(String(f.name) for f in metadata.fields)

    # TOML field extraction: by key name
    function get_toml_field(record::Dict, field_meta::FieldMetadata)
        field_key = String(field_meta.name)
        if haskey(record, field_key)
            return FieldValue(record[field_key])
        else
            return FieldValue()
        end
    end

    # TOML value conversion: TOML preserves types, just validate/convert
    function convert_toml_value_typed(field_meta::FieldMetadata, raw_value)
        return convert_toml_value(field_meta.type, raw_value)
    end

    # Unknown field callback: warn about extra fields
    function check_unknown_fields(record::Dict, record_idx::Int)
        for key in keys(record)
            if !(key in known_fields)
                @warn "Unknown field '$key' in $model_name record $record_idx (ignored)"
            end
        end
    end

    return create_named_records_generic(
        model_name, metadata, records, validation_issues;
        get_field_value = get_toml_field,
        convert_value = convert_toml_value_typed,
        on_unknown_field = check_unknown_fields
    )
end

"""
    create_indexed_records_from_toml(model_name, records) -> IndexedDynamicRecords

Create IndexedDynamicRecords from TOML (fallback when no metadata available).
"""
function create_indexed_records_from_toml(
    model_name::String,
    records::Vector
)::IndexedDynamicRecords
    @pdebug 2 "Creating indexed records for $model_name ($(length(records)) records)"

    # Convert each record dict to a vector of values
    # Note: Dict ordering is not guaranteed, so we sort by key for consistency
    fields_data = Vector{Any}[]

    for record in records
        sorted_keys = sort(collect(keys(record)))
        values = [record[k] for k in sorted_keys]
        push!(fields_data, values)
    end

    return IndexedDynamicRecords(model_name, fields_data)
end

"""
    convert_toml_value(expected_type::Type, value::Any) -> Any

Convert a TOML-parsed value to the expected type.

TOML already preserves types (Int, Float64, String, Bool), but we need to handle:
- Type mismatches (user put string where float expected)
- Automatic Int → Float64 promotion

This function is self-contained and does not depend on DYR-specific parsing functions.
"""
function convert_toml_value(expected_type::Type, value::Any)
    # Direct match - return as is
    if value isa expected_type
        return value
    end

    # Numeric promotions
    if expected_type == Float64
        if value isa Integer
            return Float64(value)
        elseif value isa AbstractString
            # Handle string representation of numbers
            s = strip(String(value))
            # Handle Fortran-style scientific notation
            s = replace(s, r"(\d)[Ee]([+-]?\d)" => s"\1e\2")
            return parse(Float64, s)
        end
    elseif expected_type == Int
        if value isa Float64 && isinteger(value)
            return Int(value)
        elseif value isa AbstractString
            return parse(Int, strip(String(value)))
        end
    elseif expected_type == String
        # Anything can become a string
        return string(value)
    elseif expected_type == Bool
        if value isa AbstractString
            s = strip(lowercase(String(value)))
            if s in ("1", "true", "t", "yes", "y")
                return true
            elseif s in ("0", "false", "f", "no", "n")
                return false
            else
                throw(ArgumentError("Cannot convert '$value' to Bool"))
            end
        elseif value isa Integer
            return value != 0
        end
    end

    # Type mismatch with no conversion path
    throw(ArgumentError("Cannot convert $(typeof(value)) '$value' to $expected_type"))
end
