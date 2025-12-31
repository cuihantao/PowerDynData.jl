# Core parsing logic for DYR files

"""
    parse_dyr(source; metadata_dir=pkgdir(PowerDynData, "metadata")) -> DynamicData

Parse a PSS/E DYR file into structured data.

# Arguments
- `source`: Path to DYR file or IO object
- `metadata_dir`: Path to metadata directory. Defaults to bundled YAML metadata at
  `pkgdir(PowerDynData, "metadata")`. Set to `nothing` to disable metadata and
  use indexed fields only. Can be set to a custom path for user-defined metadata.

# Returns
- `DynamicData`: Container with all parsed models

# Examples
```julia
# With bundled metadata (default - recommended)
dd = parse_dyr("case.dyr")

# Access models with named fields
using DataFrames
genrou_df = DataFrame(dd["GENROU"])

# Without metadata (indexed fallback)
dd = parse_dyr("case.dyr", metadata_dir=nothing)

# With custom metadata directory
dd = parse_dyr("case.dyr", metadata_dir="path/to/custom/metadata")
```
"""
function parse_dyr(
    source::Union{String, IO};
    metadata_dir::Union{String, Nothing} = pkgdir(PowerDynData, "metadata")
)::DynamicData
    # Load metadata if provided
    registry = isnothing(metadata_dir) ? nothing : load_metadata_registry(metadata_dir)

    # Get source file path
    source_path = source isa String ? source : "IO"

    # Read file content
    content = source isa String ? read(source, String) : read(source, String)

    @pdebug 1 "Parsing DYR file: $source_path"

    # Parse all records
    records = parse_all_records(content, registry)

    @pdebug 1 "Parsed $(length(records)) records"

    # Group records by model name and collect validation issues
    validation_issues = ValidationIssue[]
    models = group_records_by_model(records, registry, validation_issues)

    @pdebug 1 "Created $(length(models)) model types"
    @pdebug 1 "Encountered $(length(validation_issues)) validation issues"

    return DynamicData(models, registry, source_path, validation_issues)
end

# Parsing utilities (to be implemented)

"""
    skip_whitespace_and_comments(lines::AbstractVector{<:AbstractString}, i::Int) -> Int

Skip whitespace and comment lines, returning index of next non-comment line.

Comment markers: `@!`, `//`
"""
function skip_whitespace_and_comments(lines::AbstractVector{<:AbstractString}, i::Int)::Int
    while i <= length(lines)
        line = strip(lines[i])

        # Skip empty lines
        if isempty(line)
            i += 1
            continue
        end

        # Skip comment lines
        if startswith(line, "@!") || startswith(line, "//")
            i += 1
            continue
        end

        # Non-comment line found
        break
    end

    return i
end

"""
    detect_model_name(line::AbstractString) -> Union{String, Nothing}

Detect model name in a DYR line by finding quoted string.

Model names are enclosed in single quotes.
"""
function detect_model_name(line::AbstractString)::Union{String, Nothing}
    # Find content within single quotes
    m = match(r"'([^']+)'", line)
    return isnothing(m) ? nothing : m.captures[1]
end

"""
    parse_field(::Type{T}, s::AbstractString) -> T

Parse a single field value as type T.

Handles scientific notation (e.g., `0.60000E-01`).
"""
function parse_field(::Type{Int}, s::AbstractString)::Int
    return parse(Int, strip(s))
end

function parse_field(::Type{Float64}, s::AbstractString)::Float64
    # Handle scientific notation with E or e
    s_clean = strip(s)
    # Convert Fortran-style scientific notation if needed
    s_clean = replace(s_clean, r"(\d)E([+-]?\d)" => s"\1e\2")
    return parse(Float64, s_clean)
end

function parse_field(::Type{String}, s::AbstractString)::String
    s_clean = strip(s)
    # Remove surrounding quotes if present
    if startswith(s_clean, '\'') && endswith(s_clean, '\'')
        return s_clean[2:end-1]
    end
    return s_clean
end

function parse_field(::Type{Bool}, s::AbstractString)::Bool
    s_clean = strip(lowercase(s))
    if s_clean in ("1", "true", "t")
        return true
    elseif s_clean in ("0", "false", "f")
        return false
    else
        error("Cannot parse '$s' as Bool")
    end
end

"""
    parse_all_records(content::String, registry::Union{MetadataRegistry, Nothing}) -> Vector{ParsedRecord}

Parse all records from DYR file content.

Returns a vector of ParsedRecord structs containing model name and field values.
"""
function parse_all_records(content::String, registry::Union{MetadataRegistry, Nothing})
    lines = split(content, '\n')
    records = ParsedRecord[]

    i = 1
    while i <= length(lines)
        # Skip whitespace and comments
        i = skip_whitespace_and_comments(lines, i)
        i > length(lines) && break

        # Accumulate lines until we hit terminator /
        record_lines = String[]
        while i <= length(lines)
            line = lines[i]
            push!(record_lines, line)
            i += 1

            # Check if this line contains the terminator
            if contains(line, '/')
                break
            end
        end

        # Parse the complete record
        if !isempty(record_lines)
            record = parse_single_record(join(record_lines, " "), registry)
            if !isnothing(record)
                push!(records, record)
            end
        end
    end

    return records
end

"""
    ParsedRecord

Intermediate structure for a parsed DYR record.
"""
struct ParsedRecord
    model_name::String
    fields::Vector{String}  # Raw field strings
end

"""
    parse_single_record(record_str::String, registry::Union{MetadataRegistry, Nothing}) -> Union{ParsedRecord, Nothing}

Parse a single complete record (possibly spanning multiple lines).
"""
function parse_single_record(record_str::String, registry::Union{MetadataRegistry, Nothing})::Union{ParsedRecord, Nothing}
    # Remove terminator
    record_str = replace(record_str, "/" => "")

    # Split into fields (handling quoted strings)
    fields = split_fields(record_str)

    # Need at least 3 fields: bus, model name, id
    length(fields) < 3 && return nothing

    # Extract model name (should be in quotes in field 2)
    model_name = detect_model_name(fields[2])
    isnothing(model_name) && return nothing

    @pdebug 2 "Parsed record for model: $model_name ($(length(fields)) fields)"

    return ParsedRecord(model_name, fields)
end

"""
    split_fields(s::String) -> Vector{String}

Split a string into fields, respecting quoted strings.
"""
function split_fields(s::String)::Vector{String}
    fields = String[]
    current = ""
    in_quotes = false

    for c in s
        if c == '\''
            in_quotes = !in_quotes
            current *= c
        elseif isspace(c) && !in_quotes
            if !isempty(strip(current))
                push!(fields, strip(current))
                current = ""
            end
        else
            current *= c
        end
    end

    # Add last field
    if !isempty(strip(current))
        push!(fields, strip(current))
    end

    return fields
end

"""
    group_records_by_model(records::Vector{ParsedRecord}, registry::Union{MetadataRegistry, Nothing}, validation_issues::Vector{ValidationIssue}) -> Dict{String, DynamicRecords}

Group parsed records by model name and create DynamicRecords for each model type.
"""
function group_records_by_model(records::Vector{ParsedRecord}, registry::Union{MetadataRegistry, Nothing}, validation_issues::Vector{ValidationIssue})
    # Group by model name
    groups = Dict{String, Vector{ParsedRecord}}()
    for record in records
        if !haskey(groups, record.model_name)
            groups[record.model_name] = ParsedRecord[]
        end
        push!(groups[record.model_name], record)
    end

    # Convert each group to DynamicRecords
    models = Dict{String, DynamicRecords}()
    for (model_name, model_records) in groups
        metadata = isnothing(registry) ? nothing : get_model_metadata(registry, model_name)

        if isnothing(metadata)
            # Fallback: indexed fields
            models[model_name] = create_indexed_records(model_name, model_records)
        else
            # Use metadata for named fields
            models[model_name] = create_named_records(model_name, metadata, model_records, validation_issues)
        end
    end

    return models
end

"""
    create_indexed_records(model_name::String, records::Vector{ParsedRecord}) -> IndexedDynamicRecords

Create IndexedDynamicRecords (fallback when no metadata available).
"""
function create_indexed_records(model_name::String, records::Vector{ParsedRecord})
    @pdebug 2 "Creating indexed records for $model_name ($(length(records)) records)"

    # Extract fields as vectors of vectors
    fields_data = [record.fields for record in records]

    return IndexedDynamicRecords(model_name, fields_data)
end

"""
    create_named_records(model_name::String, metadata::ModelMetadata, records::Vector{ParsedRecord}, validation_issues::Vector{ValidationIssue}) -> NamedDynamicRecords

Create NamedDynamicRecords using metadata schema.
"""
function create_named_records(model_name::String, metadata::ModelMetadata, records::Vector{ParsedRecord}, validation_issues::Vector{ValidationIssue})
    # DYR field extraction: by position in record.fields
    function get_dyr_field(record::ParsedRecord, field_meta::FieldMetadata)
        pos = field_meta.position
        if pos <= length(record.fields)
            return FieldValue(record.fields[pos])
        else
            return FieldValue()
        end
    end

    # DYR value conversion: parse string to expected type
    function convert_dyr_value(field_meta::FieldMetadata, raw_value::String)
        return parse_field(field_meta.type, raw_value)
    end

    return create_named_records_generic(
        model_name, metadata, records, validation_issues;
        get_field_value = get_dyr_field,
        convert_value = convert_dyr_value
    )
end
