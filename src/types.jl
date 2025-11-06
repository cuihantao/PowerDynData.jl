# Type definitions for PowerDynData

"""
    $TYPEDEF

Represents a validation issue encountered during parsing.

# Fields
$TYPEDFIELDS
"""
struct ValidationIssue
    "Model name where issue occurred"
    model_name::String
    "Record index (1-based) within the model"
    record_index::Int
    "Field name where issue occurred"
    field_name::Symbol
    "Type of issue (:out_of_range, :parse_error, etc.)"
    issue_type::Symbol
    "Human-readable message"
    message::String
    "The actual value that caused the issue"
    value::Any
end

"""
    $TYPEDEF

Abstract base type for all dynamic record collections.
"""
abstract type DynamicRecords end

"""
    $TYPEDEF

Dynamic records with metadata-driven named fields.

# Fields
$TYPEDFIELDS
"""
struct NamedDynamicRecords{T} <: DynamicRecords
    "Model name (e.g., 'GENROU', 'ESST3A')"
    model_name::String
    "Model category (e.g., 'generator', 'exciter')"
    category::String
    "StructArray containing the actual data with named columns"
    data::T
end

"""
    $TYPEDEF

Dynamic records without metadata (fallback mode with indexed fields).

# Fields
$TYPEDFIELDS
"""
struct IndexedDynamicRecords <: DynamicRecords
    "Model name"
    model_name::String
    "Raw field data as vector of vectors"
    fields::Vector{Vector{Any}}
end

"""
    $TYPEDEF

Top-level container for all dynamic data from a DYR file.

# Fields
$TYPEDFIELDS

# Examples
```julia
dd = parse_dyr("case.dyr", metadata_dir="metadata")

# Access models
genrou = dd["GENROU"]
tgov1 = dd["TGOV1"]

# Get available models
keys(dd)

# Check validation issues
if !isempty(dd.validation_issues)
    for issue in dd.validation_issues
        println("\$(issue.model_name)[\$(issue.record_index)].\$(issue.field_name): \$(issue.message)")
    end
end

# Convert to DataFrame
using DataFrames
df = DataFrame(dd["GENROU"])
```
"""
struct DynamicData
    "Dictionary mapping model names to their records"
    models::Dict{String, DynamicRecords}
    "Metadata registry (if loaded)"
    metadata_registry::Union{MetadataRegistry, Nothing}
    "Source file path"
    source_file::String
    "Validation issues encountered during parsing"
    validation_issues::Vector{ValidationIssue}
end

# Convenience accessors for DynamicData
Base.getindex(dd::DynamicData, model::String) = dd.models[model]
Base.keys(dd::DynamicData) = keys(dd.models)
Base.haskey(dd::DynamicData, model::String) = haskey(dd.models, model)
Base.length(dd::DynamicData) = length(dd.models)

# Tables.jl interface for NamedDynamicRecords
Tables.istable(::Type{<:NamedDynamicRecords}) = true
Tables.columnaccess(::Type{<:NamedDynamicRecords}) = true
Tables.columns(x::NamedDynamicRecords) = x.data
Tables.columnnames(x::NamedDynamicRecords) = propertynames(x.data)
Tables.getcolumn(x::NamedDynamicRecords, i::Int) = getfield(x.data, i)
Tables.getcolumn(x::NamedDynamicRecords, nm::Symbol) = getproperty(x.data, nm)
Base.length(x::NamedDynamicRecords) = length(x.data)

# Length for IndexedDynamicRecords
Base.length(x::IndexedDynamicRecords) = length(x.fields)

# Pretty printing
function Base.show(io::IO, dd::DynamicData)
    n_models = length(dd.models)
    n_records = sum(length(r.data) for r in values(dd.models) if r isa NamedDynamicRecords; init=0)
    has_metadata = !isnothing(dd.metadata_registry)

    print(io, "DynamicData(")
    print(io, "$n_models models, ")
    print(io, "$n_records records")
    has_metadata && print(io, ", with metadata")
    print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", dd::DynamicData)
    println(io, "DynamicData from: ", basename(dd.source_file))
    println(io, "  Models: ", join(sort(collect(keys(dd))), ", "))
    if !isnothing(dd.metadata_registry)
        println(io, "  Metadata: loaded (", length(dd.metadata_registry.models), " model schemas)")
    else
        println(io, "  Metadata: not loaded")
    end

    # Show validation issues if any
    if !isempty(dd.validation_issues)
        n_issues = length(dd.validation_issues)
        out_of_range = count(x -> x.issue_type == :out_of_range, dd.validation_issues)
        parse_errors = count(x -> x.issue_type == :parse_error, dd.validation_issues)
        print(io, "  Validation issues: $n_issues total")
        if out_of_range > 0
            print(io, " ($out_of_range out-of-range")
        end
        if parse_errors > 0
            print(io, out_of_range > 0 ? ", " : " (")
            print(io, "$parse_errors parse errors")
        end
        println(io, ")")
    end
end

function Base.show(io::IO, r::NamedDynamicRecords)
    n = length(r.data)
    print(io, "NamedDynamicRecords($(r.model_name), $n records)")
end

function Base.show(io::IO, r::IndexedDynamicRecords)
    n = length(r.fields)
    print(io, "IndexedDynamicRecords($(r.model_name), $n records)")
end
