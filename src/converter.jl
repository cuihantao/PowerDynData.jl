# DYR to TOML converter

"""
    dyr_to_toml(dyr_source, toml_dest; metadata_dir=...) -> String

Convert a DYR file to TOML format.

# Arguments
- `dyr_source`: Path to DYR file or IO object
- `toml_dest`: Path to output TOML file or IO object
- `metadata_dir`: Path to metadata directory (defaults to bundled metadata)

# Returns
- Path to the created TOML file (if file path given) or the destination IO

# Examples
```julia
# Convert file
dyr_to_toml("case.dyr", "case.toml")

# Convert to IO
io = IOBuffer()
dyr_to_toml("case.dyr", io)
toml_string = String(take!(io))
```
"""
function dyr_to_toml(
    dyr_source::Union{String, IO},
    toml_dest::Union{String, IO};
    metadata_dir::Union{String, Nothing} = pkgdir(PowerDynData, "metadata")
)
    # Parse DYR file
    dd = parse_dyr(dyr_source; metadata_dir)

    # Build TOML structure
    toml_data = Dict{String, Vector{Dict{String, Any}}}()

    for (model_name, records) in dd.models
        if records isa NamedDynamicRecords
            toml_data[model_name] = named_records_to_dicts(records)
        else
            toml_data[model_name] = indexed_records_to_dicts(records)
        end
    end

    # Write TOML
    if toml_dest isa String
        open(toml_dest, "w") do io
            TOML.print(io, toml_data)
        end
    else
        TOML.print(toml_dest, toml_data)
    end

    return toml_dest
end

"""
    named_records_to_dicts(records::NamedDynamicRecords) -> Vector{Dict{String, Any}}

Convert NamedDynamicRecords to a vector of dictionaries for TOML output.
"""
function named_records_to_dicts(records::NamedDynamicRecords)::Vector{Dict{String, Any}}
    result = Dict{String, Any}[]
    n = length(records)

    for i in 1:n
        record = Dict{String, Any}()
        for name in propertynames(records.data)
            record[String(name)] = getproperty(records.data, name)[i]
        end
        push!(result, record)
    end

    return result
end

"""
    indexed_records_to_dicts(records::IndexedDynamicRecords) -> Vector{Dict{String, Any}}

Convert IndexedDynamicRecords to a vector of dictionaries for TOML output.
Uses indexed field names (field_1, field_2, etc.) since no metadata is available.
"""
function indexed_records_to_dicts(records::IndexedDynamicRecords)::Vector{Dict{String, Any}}
    result = Dict{String, Any}[]

    for fields in records.fields
        record = Dict{String, Any}()
        for (i, value) in enumerate(fields)
            record["field_$i"] = value
        end
        push!(result, record)
    end

    return result
end
