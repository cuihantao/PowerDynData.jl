# Shared record creation logic for DYR and TOML parsing
# Eliminates code duplication between parsing.jl and toml_parsing.jl

"""
    FieldValue

Represents a field value extraction result.
- `found`: Whether the field was found in the source
- `raw_value`: The raw value (only valid if found=true)
"""
struct FieldValue{T}
    found::Bool
    raw_value::T
end

FieldValue() = FieldValue{Nothing}(false, nothing)
FieldValue(value) = FieldValue{typeof(value)}(true, value)

"""
    create_named_records_generic(
        model_name, metadata, records, validation_issues;
        get_field_value, convert_value, on_unknown_field=nothing
    ) -> NamedDynamicRecords

Generic function to create NamedDynamicRecords from any source format.

# Arguments
- `model_name`: Name of the model (e.g., "GENROU")
- `metadata`: ModelMetadata with field definitions
- `records`: Vector of source records (format-specific)
- `validation_issues`: Vector to collect validation issues

# Keyword Arguments
- `get_field_value(record, field_meta) -> FieldValue`: Extract field value from record
- `convert_value(field_meta, raw_value) -> value`: Convert raw value to expected type
- `on_unknown_field(record, record_idx) -> nothing`: Optional callback for unknown field detection
"""
function create_named_records_generic(
    model_name::String,
    metadata::ModelMetadata,
    records::Vector,
    validation_issues::Vector{ValidationIssue};
    get_field_value::Function,
    convert_value::Function,
    on_unknown_field::Union{Function, Nothing} = nothing
)::NamedDynamicRecords
    @pdebug 2 "Creating named records for $model_name ($(length(records)) records, $(length(metadata.fields)) fields)"

    # Initialize storage for each field
    field_data = Dict{Symbol, Vector{Any}}()
    for field_meta in metadata.fields
        field_data[field_meta.name] = Any[]
    end

    # Parse each record
    for (record_idx, record) in enumerate(records)
        # Check for unknown fields if callback provided
        if !isnothing(on_unknown_field)
            on_unknown_field(record, record_idx)
        end

        for field_meta in metadata.fields
            field_value = get_field_value(record, field_meta)

            if field_value.found
                raw_value = field_value.raw_value

                # Convert and validate
                try
                    value = convert_value(field_meta, raw_value)

                    # Range validation (non-blocking)
                    validate_field_range!(
                        validation_issues, model_name, record_idx,
                        field_meta, value
                    )

                    push!(field_data[field_meta.name], value)
                catch e
                    # Record parse/conversion error
                    handle_conversion_error!(
                        field_data, validation_issues,
                        model_name, record_idx, field_meta, raw_value, e
                    )
                end
            else
                # Field not found - handle missing field
                handle_missing_field!(
                    field_data, validation_issues,
                    model_name, record_idx, field_meta
                )
            end
        end
    end

    # Convert to proper types and create StructArray
    typed_data = create_typed_vectors(field_data, metadata.fields)

    # Create StructArray
    sa = StructArray(; typed_data...)

    return NamedDynamicRecords(model_name, metadata.category, sa)
end

"""
    validate_field_range!(validation_issues, model_name, record_idx, field_meta, value)

Check if value is within the valid range and record validation issue if not.
"""
function validate_field_range!(
    validation_issues::Vector{ValidationIssue},
    model_name::String,
    record_idx::Int,
    field_meta::FieldMetadata,
    value
)
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
end

"""
    handle_conversion_error!(field_data, validation_issues, model_name, record_idx, field_meta, raw_value, error)

Handle a value conversion error by recording the issue and using the default value.
"""
function handle_conversion_error!(
    field_data::Dict{Symbol, Vector{Any}},
    validation_issues::Vector{ValidationIssue},
    model_name::String,
    record_idx::Int,
    field_meta::FieldMetadata,
    raw_value,
    error
)
    @warn "Failed to convert field $(field_meta.name): $error"

    issue = ValidationIssue(
        model_name,
        record_idx,
        field_meta.name,
        :parse_error,
        "Failed to convert: $error",
        raw_value
    )
    push!(validation_issues, issue)

    # Use default or missing
    default_val = something(field_meta.default, missing)
    push!(field_data[field_meta.name], default_val)
end

"""
    handle_missing_field!(field_data, validation_issues, model_name, record_idx, field_meta)

Handle a missing field by recording validation issue (if required) and using default.
"""
function handle_missing_field!(
    field_data::Dict{Symbol, Vector{Any}},
    validation_issues::Vector{ValidationIssue},
    model_name::String,
    record_idx::Int,
    field_meta::FieldMetadata
)
    if field_meta.required && isnothing(field_meta.default)
        # Required field without default - this is a critical issue
        issue = ValidationIssue(
            model_name,
            record_idx,
            field_meta.name,
            :missing_required,
            "Required field $(field_meta.name) is missing with no default value",
            nothing
        )
        push!(validation_issues, issue)
    elseif field_meta.required
        # Required field with default - still record as issue but use default
        issue = ValidationIssue(
            model_name,
            record_idx,
            field_meta.name,
            :missing_field,
            "Required field $(field_meta.name) missing, using default",
            nothing
        )
        push!(validation_issues, issue)
    end

    # Use default or missing
    default_val = something(field_meta.default, missing)
    push!(field_data[field_meta.name], default_val)
end

"""
    create_typed_vectors(field_data, field_metas) -> Dict{Symbol, Vector}

Convert heterogeneous field data vectors to properly typed vectors.
"""
function create_typed_vectors(
    field_data::Dict{Symbol, Vector{Any}},
    field_metas::Vector{FieldMetadata}
)::Dict{Symbol, Vector}
    typed_data = Dict{Symbol, Vector}()

    for field_meta in field_metas
        raw_vec = field_data[field_meta.name]
        if all(x -> x isa field_meta.type, raw_vec)
            typed_data[field_meta.name] = convert(Vector{field_meta.type}, raw_vec)
        else
            # Has missing values or type mismatch - keep as Any
            typed_data[field_meta.name] = raw_vec
        end
    end

    return typed_data
end
