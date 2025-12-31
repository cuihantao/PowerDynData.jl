# TOML parsing for dynamic data
# Alternative to DYR format with explicit field names

"""
Maximum allowed size for TOML data files (in bytes).
Large power system models may have substantial data files, but >100MB likely indicates an error.
"""
const MAX_TOML_FILE_SIZE = 100 * 1024 * 1024  # 100 MB

"""
    parse_toml(source; metadata_dir=pkgdir(PowerDynData, "metadata")) -> DynamicData

Parse a TOML file containing dynamic model data into structured data.

Uses named fields (e.g., `BUS = 1`, `H = 4.0`) instead of positional fields.
Returns the same `DynamicData` structure as `parse_dyr` for interoperability.

# Arguments
- `source`: Path to TOML file or IO object
- `metadata_dir`: Path to metadata directory. Defaults to bundled YAML metadata at
  `pkgdir(PowerDynData, "metadata")`. Set to `nothing` to disable metadata and
  use indexed fields only.

# Returns
- `DynamicData`: Container with all parsed models (same structure as `parse_dyr`)

# TOML Format
Use `[[MODEL_NAME]]` for each device instance with named fields:
```toml
[[GENROU]]
BUS = 1
ID = "1"
H = 4.0    # Comments supported
```
Field names must match metadata YAML definitions exactly (case-sensitive).

# Validation
- Unknown fields generate warnings but parsing continues
- Out-of-range values recorded in `dd.validation_issues`
- Type mismatches attempt conversion; failures recorded as parse errors

# Examples
```julia
# With bundled metadata (default - recommended)
dd = parse_toml("case.toml")

# Access models with named fields
using DataFrames
genrou_df = DataFrame(dd["GENROU"])

# Without metadata (indexed fallback)
dd = parse_toml("case.toml", metadata_dir=nothing)

# With custom metadata directory
dd = parse_toml("case.toml", metadata_dir="path/to/custom/metadata")
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

    # Validate file size if reading from file path
    if source isa String
        file_size = filesize(source)
        if file_size > MAX_TOML_FILE_SIZE
            error("TOML file too large: $source ($(file_size ÷ (1024*1024)) MB > $(MAX_TOML_FILE_SIZE ÷ (1024*1024)) MB)")
        end
    end

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
