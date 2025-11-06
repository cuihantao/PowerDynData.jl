# Core parsing logic for DYR files

"""
    parse_dyr(source; metadata_dir=pkgdir(PowerDynData, "metadata")) -> DynamicData

Parse a PSS/E DYR file into structured data.

# Arguments
- `source`: Path to DYR file or IO object
- `metadata_dir`: Path to metadata directory. Defaults to bundled metadata at
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
    skip_whitespace_and_comments(lines::Vector{SubString{String}}, i::Int) -> Int

Skip whitespace and comment lines, returning index of next non-comment line.

Comment markers: `@!`, `//`
"""
function skip_whitespace_and_comments(lines::Vector{SubString{String}}, i::Int)::Int
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
        i = skip_whitespace_and_comments_vec(lines, i)
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
    skip_whitespace_and_comments_vec(lines::Vector{SubString{String}}, i::Int) -> Int

Skip whitespace and comment lines.
"""
function skip_whitespace_and_comments_vec(lines::Vector{SubString{String}}, i::Int)::Int
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
    @pdebug 2 "Creating named records for $model_name ($(length(records)) records, $(length(metadata.fields)) fields)"

    # Initialize storage for each field
    field_data = Dict{Symbol, Vector{Any}}()
    for field_meta in metadata.fields
        field_data[field_meta.name] = Any[]
    end

    # Parse each record
    for (record_idx, record) in enumerate(records)
        for field_meta in metadata.fields
            pos = field_meta.position

            # Get raw field value
            if pos <= length(record.fields)
                raw_value = record.fields[pos]

                # Parse according to type
                try
                    value = parse_field(field_meta.type, raw_value)

                    # Check range if specified (but don't error - just record the issue)
                    if !isnothing(field_meta.range) && value isa Number
                        min_val, max_val = field_meta.range
                        if value < min_val || value > max_val
                            issue = ValidationIssue(
                                model_name,
                                record_idx,
                                field_meta.name,
                                :out_of_range,
                                "Value $value outside valid range [$min_val, $max_val]",
                                value
                            )
                            push!(validation_issues, issue)
                        end
                    end

                    # Always push the actual value (even if out of range)
                    push!(field_data[field_meta.name], value)
                catch e
                    @warn "Failed to parse field $(field_meta.name) at position $pos: $e"
                    # Record parse error
                    issue = ValidationIssue(
                        model_name,
                        record_idx,
                        field_meta.name,
                        :parse_error,
                        "Failed to parse: $e",
                        raw_value
                    )
                    push!(validation_issues, issue)

                    # Use default or push missing
                    default_val = something(field_meta.default, missing)
                    push!(field_data[field_meta.name], default_val)
                end
            else
                # Field not present - use default
                default_val = something(field_meta.default, missing)
                push!(field_data[field_meta.name], default_val)
            end
        end
    end

    # Convert to proper types and create StructArray
    typed_data = Dict{Symbol, Vector}()
    for field_meta in metadata.fields
        # Convert to proper vector type
        raw_vec = field_data[field_meta.name]
        if all(x -> x isa field_meta.type, raw_vec)
            typed_data[field_meta.name] = convert(Vector{field_meta.type}, raw_vec)
        else
            # Has missing values or type mismatch
            typed_data[field_meta.name] = raw_vec
        end
    end

    # Create StructArray
    sa = StructArray(; typed_data...)

    return NamedDynamicRecords(model_name, metadata.category, sa)
end
